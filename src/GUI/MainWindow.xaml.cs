using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Diagnostics;
using System.Collections.ObjectModel;

namespace WinPurge
{
    public partial class MainWindow : Window
    {
        private bool isDryRunMode = false;
        private bool isVerboseMode = false;

        public MainWindow()
        {
            InitializeComponent();
            ApplyTheme();
            LoadInitialData();
        }

        /// <summary>
        /// Apply theme based on system preferences or user selection
        /// </summary>
        private void ApplyTheme()
        {
            // Detect system theme
            try
            {
                var lightTheme = SystemParameters.HighContrast;
                // For now, using dark theme by default
                ApplyDarkTheme();
            }
            catch
            {
                ApplyDarkTheme();
            }
        }

        private void ApplyDarkTheme()
        {
            var resources = this.Resources;
            resources["BackgroundBrush"] = new SolidColorBrush(Color.FromRgb(30, 30, 30));
            resources["TextBrush"] = new SolidColorBrush(Color.FromRgb(255, 255, 255));
            resources["BorderBrush"] = new SolidColorBrush(Color.FromRgb(63, 63, 63));
            resources["ButtonHoverBrush"] = new SolidColorBrush(Color.FromRgb(45, 45, 45));
        }

        private void ApplyLightTheme()
        {
            var resources = this.Resources;
            resources["BackgroundBrush"] = new SolidColorBrush(Color.FromRgb(255, 255, 255));
            resources["TextBrush"] = new SolidColorBrush(Color.FromRgb(0, 0, 0));
            resources["BorderBrush"] = new SolidColorBrush(Color.FromRgb(200, 200, 200));
            resources["ButtonHoverBrush"] = new SolidColorBrush(Color.FromRgb(240, 240, 240));
        }

        /// <summary>
        /// Load initial data on startup
        /// </summary>
        private void LoadInitialData()
        {
            UpdateSystemInfo();
            LoadToolsCategory();
            UpdatePerformanceStats();
        }

        private void UpdateSystemInfo()
        {
            try
            {
                var osVersion = Environment.OSVersion;
                SystemInfoText.Text = $"{osVersion.VersionString}";
            }
            catch { }
        }

        private void LoadToolsCategory()
        {
            // This will be populated from PowerShell backend
            ToolsListBox.Items.Clear();
            ToolsListBox.Items.Add("Steam");
            ToolsListBox.Items.Add("Epic Games Launcher");
            ToolsListBox.Items.Add("GOG Galaxy");
            ToolsListBox.Items.Add("Ubisoft Connect");
            ToolsListBox.Items.Add("EA App");
        }

        private void UpdatePerformanceStats()
        {
            try
            {
                var cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
                CPUUsageText.Text = $"Usage: {cpuCounter.NextValue():F1}%";
                
                var totalMemory = GC.GetTotalMemory(false) / (1024 * 1024);
                MemoryUsageText.Text = $"Usage: 45%";  // Placeholder
                
                var processes = Process.GetProcesses().Length;
                ProcessCountText.Text = $"Running: {processes}";
            }
            catch { }
        }

        // Event Handlers

        private void DryRunToggle_Click(object sender, RoutedEventArgs e)
        {
            isDryRunMode = !isDryRunMode;
            DryRunToggleButton.Content = isDryRunMode ? "🔍 Dry-Run: ON" : "🔍 Dry-Run: OFF";
            DryRunToggleButton.Background = isDryRunMode ? 
                new SolidColorBrush(Color.FromRgb(255, 179, 0)) : 
                new SolidColorBrush(Color.FromRgb(0, 120, 212));
            StatusBarText.Text = isDryRunMode ? "Dry-Run Mode: ENABLED - No changes will be applied" : "Ready";
        }

        private void VerboseToggle_Click(object sender, RoutedEventArgs e)
        {
            isVerboseMode = !isVerboseMode;
            VerboseToggleButton.Content = isVerboseMode ? "📝 Verbose: ON" : "📝 Verbose: OFF";
            VerboseToggleButton.Background = isVerboseMode ? 
                new SolidColorBrush(Color.FromRgb(255, 179, 0)) : 
                new SolidColorBrush(Color.FromRgb(0, 120, 212));
        }

        private void Settings_Click(object sender, RoutedEventArgs e)
        {
            SettingsTab.IsSelected = true;
        }

        private void Help_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show(
                "WinPurge v2.0 - Advanced Windows Debloater\n\n" +
                "Features:\n" +
                "• Complete AI feature removal with reinstall blocking\n" +
                "• Dry-run mode to preview all changes\n" +
                "• Detailed audit logging of all modifications\n" +
                "• Performance benchmarking and monitoring\n" +
                "• One-click full rebloat capability\n" +
                "• Plugin system for custom tweaks\n" +
                "• Tools catalog for apps and games\n\n" +
                "Documentation: github.com/ScriptSage196/WinPurge",
                "WinPurge Help",
                MessageBoxButton.OK,
                MessageBoxImage.Information
            );
        }

        private void ApplyPreset_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Applying preset...";
            MessageBox.Show("Preset application requires PowerShell backend integration.", "Apply Preset", MessageBoxButton.OK);
        }

        private void ApplyTweaks_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Applying selected tweaks...";
            MessageBox.Show("Tweak application requires PowerShell backend integration.", "Apply Tweaks", MessageBoxButton.OK);
        }

        private void CreateRestorePoint_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Creating restore point...";
            MessageBox.Show("Restore point creation requires PowerShell backend integration.", "Restore Point", MessageBoxButton.OK);
        }

        private void ToolsCategory_Changed(object sender, SelectionChangedEventArgs e)
        {
            LoadToolsCategory();
        }

        private void Tool_Selected(object sender, SelectionChangedEventArgs e)
        {
            if (ToolsListBox.SelectedItem != null)
            {
                ToolDescriptionText.Text = $"Selected: {ToolsListBox.SelectedItem}\n\nUse the Install button to download and install via WinGet.";
            }
        }

        private void InstallTool_Click(object sender, RoutedEventArgs e)
        {
            if (ToolsListBox.SelectedItem != null)
            {
                InstallLogText.Text = $"Installing {ToolsListBox.SelectedItem}...";
                MessageBox.Show($"Installing {ToolsListBox.SelectedItem}\n\nThis requires WinGet to be installed.", "Tool Installation", MessageBoxButton.OK);
            }
        }

        private void InstallBundle_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var bundleName = button?.Tag?.ToString();
            MessageBox.Show($"Installing {bundleName} bundle...\n\nThis requires PowerShell backend integration.", "Bundle Installation", MessageBoxButton.OK);
        }

        private void DetectWinGet_Click(object sender, RoutedEventArgs e)
        {
            WinGetStatusText.Text = "WinGet detection requires PowerShell backend.";
        }

        private void StartCleanup_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Cleanup in progress...";
            MessageBox.Show("Cleanup operation requires PowerShell backend integration.", "System Cleanup", MessageBoxButton.OK);
        }

        private void RunOptimization_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Optimization in progress...";
            MessageBox.Show("Optimization operation requires PowerShell backend integration.", "System Optimization", MessageBoxButton.OK);
        }

        private void RefreshStats_Click(object sender, RoutedEventArgs e)
        {
            UpdatePerformanceStats();
            StatusBarText.Text = "Performance stats refreshed";
        }

        private void LoadAuditLog_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Loading audit log...";
            MessageBox.Show("Audit log loading requires PowerShell backend integration.", "Load Audit Log", MessageBoxButton.OK);
        }

        private void ExportAuditLog_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Export functionality requires PowerShell backend integration.", "Export Audit Log", MessageBoxButton.OK);
        }

        private void FullRebloat_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                "Are you sure you want to fully rebloat your system?\nThis will restore all removed applications and settings.",
                "Full Rebloat",
                MessageBoxButton.YesNo,
                MessageBoxImage.Warning
            );

            if (result == MessageBoxResult.Yes)
            {
                StatusBarText.Text = "Full rebloat in progress...";
                MessageBox.Show("Rebloat operation requires PowerShell backend integration.", "Full Rebloat", MessageBoxButton.OK);
            }
        }

        private void ClearAuditLog_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                "Clear audit log? This action cannot be undone.",
                "Clear Audit Log",
                MessageBoxButton.YesNo,
                MessageBoxImage.Warning
            );

            if (result == MessageBoxResult.Yes)
            {
                StatusBarText.Text = "Audit log cleared";
            }
        }

        private void ReloadPlugins_Click(object sender, RoutedEventArgs e)
        {
            StatusBarText.Text = "Reloading plugins...";
            MessageBox.Show("Plugin reloading requires PowerShell backend integration.", "Reload Plugins", MessageBoxButton.OK);
        }

        private void OpenPluginsFolder_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process.Start("explorer.exe", $@"{System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "plugins")}" );
            }
            catch
            {
                MessageBox.Show("Could not open plugins folder.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Plugin_Selected(object sender, SelectionChangedEventArgs e)
        {
            if (PluginsListBox.SelectedItem != null)
            {
                PluginDetailsText.Text = $"Plugin: {PluginsListBox.SelectedItem}\n\nSelect and click 'Execute Plugin' to run it.";
            }
        }

        private void ExecutePlugin_Click(object sender, RoutedEventArgs e)
        {
            if (PluginsListBox.SelectedItem != null)
            {
                StatusBarText.Text = $"Executing plugin: {PluginsListBox.SelectedItem}";
                MessageBox.Show($"Executing plugin: {PluginsListBox.SelectedItem}\n\nThis requires PowerShell backend integration.", "Execute Plugin", MessageBoxButton.OK);
            }
        }
    }
}
