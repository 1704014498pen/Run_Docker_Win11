using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Security.Principal;
using System.Windows.Forms;

namespace DockerControl
{
    public class MainForm : Form
    {
        static readonly string DockerExe = @"C:\Program Files\Docker\Docker\Docker Desktop.exe";
        static readonly string[] ProcNames = {
            "Docker Desktop", "com.docker.backend", "com.docker.build",
            "docker-agent", "docker-sandbox", "com.docker.cli"
        };

        Label statusLabel;
        Button btnStop;
        Button btnStart;
        TextBox logBox;
        Timer timer;

        public MainForm()
        {
            Text = "Docker Control (Win11)";
            ClientSize = new Size(420, 340);
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;

            statusLabel = new Label {
                Location = new Point(20, 18),
                Size = new Size(370, 28),
                Font = new Font("Segoe UI", 11F, FontStyle.Bold)
            };
            Controls.Add(statusLabel);

            btnStop = new Button {
                Location = new Point(20, 58),
                Size = new Size(180, 58),
                Text = "STOP Docker",
                Font = new Font("Segoe UI", 11F, FontStyle.Bold),
                BackColor = Color.MistyRose
            };
            btnStop.Click += (s, e) => InvokeStop();
            Controls.Add(btnStop);

            btnStart = new Button {
                Location = new Point(210, 58),
                Size = new Size(180, 58),
                Text = "START Docker",
                Font = new Font("Segoe UI", 11F, FontStyle.Bold),
                BackColor = Color.Honeydew
            };
            btnStart.Click += (s, e) => InvokeStart();
            Controls.Add(btnStart);

            logBox = new TextBox {
                Location = new Point(20, 130),
                Size = new Size(370, 180),
                Multiline = true,
                ReadOnly = true,
                ScrollBars = ScrollBars.Vertical,
                Font = new Font("Consolas", 9F),
                BackColor = Color.Black,
                ForeColor = Color.LightGreen
            };
            Controls.Add(logBox);

            timer = new Timer { Interval = 2000 };
            timer.Tick += (s, e) => UpdateStatus();
            timer.Start();

            UpdateStatus();
            bool admin = new WindowsPrincipal(WindowsIdentity.GetCurrent()).IsInRole(WindowsBuiltInRole.Administrator);
            Log("Docker Control ready. admin=" + admin);
            if (!admin) Log("WARN: not elevated. STOP may fail.");
        }

        void Log(string msg)
        {
            logBox.AppendText("[" + DateTime.Now.ToString("HH:mm:ss") + "] " + msg + "\r\n");
            logBox.SelectionStart = logBox.Text.Length;
            logBox.ScrollToCaret();
        }

        void UpdateStatus()
        {
            bool running = Process.GetProcessesByName("Docker Desktop").Length > 0;
            statusLabel.Text = running ? "Status: RUNNING" : "Status: STOPPED";
            statusLabel.ForeColor = running ? Color.ForestGreen : Color.Gray;
        }

        void InvokeStop()
        {
            btnStop.Enabled = false;
            btnStart.Enabled = false;
            try
            {
                Log("Stopping Docker processes...");
                foreach (string name in ProcNames)
                {
                    foreach (Process p in Process.GetProcessesByName(name))
                    {
                        try { p.Kill(); Log("  killed: " + name); } catch { }
                    }
                }
                Log("wsl --shutdown ...");
                var psi = new ProcessStartInfo("wsl.exe", "--shutdown")
                {
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };
                using (Process proc = Process.Start(psi))
                {
                    string outp = proc.StandardOutput.ReadToEnd() + proc.StandardError.ReadToEnd();
                    proc.WaitForExit();
                    if (!string.IsNullOrWhiteSpace(outp))
                    {
                        foreach (string line in outp.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries))
                            Log("  " + line);
                    }
                }
                Log("Stop complete.");
            }
            catch (Exception ex) { Log("ERROR: " + ex.Message); }
            finally
            {
                UpdateStatus();
                btnStop.Enabled = true;
                btnStart.Enabled = true;
            }
        }

        void InvokeStart()
        {
            if (!File.Exists(DockerExe))
            {
                Log("ERROR: not found -> " + DockerExe);
                return;
            }
            Log("Starting Docker Desktop...");
            Process.Start(DockerExe);
            Log("Launch sent. (engine takes ~10-30s)");
            UpdateStatus();
        }

        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }
}
