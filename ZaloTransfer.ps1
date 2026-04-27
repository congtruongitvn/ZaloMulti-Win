# ============================================================
# ZALOTRANSFER - CÔNG CỤ SAO LƯU & DI CƯ PROFILE ZALO
# BẢN QUYỀN TRUONG.IT
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Đường dẫn mặc định (Lấy từ cấu hình ZaloMulti nếu có)
$ProfileRoot = "C:\Zalo_Clone_Profiles"
$CustomPathFile = Join-Path $PSScriptRoot "custom_path.txt"
if (Test-Path $CustomPathFile) {
    $ProfileRoot = (Get-Content $CustomPathFile -Raw).Trim()
}

function Show-Msg {
    param($msg, $title = "ZaloTransfer", $icon = [System.Windows.Forms.MessageBoxIcon]::Information)
    [System.Windows.Forms.MessageBox]::Show($msg, $title, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

# --- CHỨC NĂNG SAO LƯU ---
function Export-ZaloProfile {
    $profiles = Get-ChildItem $ProfileRoot | Where-Object { $_.PSIsContainer }
    if ($profiles.Count -eq 0) { Show-Msg "Không tìm thấy profile nào để sao lưu!" "Lỗi" [System.Windows.Forms.MessageBoxIcon]::Error; return }

    # Hiển thị menu chọn profile
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Chọn Profile để Sao Lưu"
    $form.Size = New-Object System.Drawing.Size(300, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"

    $lb = New-Object System.Windows.Forms.ListBox
    $lb.Dock = "Fill"
    foreach ($p in $profiles) { $lb.Items.Add($p.Name) }
    $form.Controls.Add($lb)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "SAO LƯU NGAY"
    $btn.Dock = "Bottom"
    $btn.Height = 40
    $btn.Add_Click({ $form.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.Close() })
    $form.Controls.Add($btn)

    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK -and $lb.SelectedItem) {
        $name = $lb.SelectedItem
        $sourcePath = Join-Path $ProfileRoot $name
        
        $save = New-Object System.Windows.Forms.SaveFileDialog
        $save.Filter = "Zalo Profile Package (*.zlp)|*.zlp"
        $save.FileName = "Backup_Zalo_$name.zlp"
        
        if ($save.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $destZip = $save.FileName
            if (Test-Path $destZip) { Remove-Item $destZip }
            
            Write-Host "Đang nén dữ liệu profile '$name'..." -ForegroundColor Cyan
            Compress-Archive -Path "$sourcePath\*" -DestinationPath $destZip -Force
            Show-Msg "Đã sao lưu thành công profile '$name' ra file:`n$destZip"
        }
    }
}

# --- CHỨC NĂNG KHÔI PHỤC ---
function Import-ZaloProfile {
    $open = New-Object System.Windows.Forms.OpenFileDialog
    $open.Filter = "Zalo Profile Package (*.zlp)|*.zlp"
    
    if ($open.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $zipFile = $open.FileName
        $defaultName = [System.IO.Path]::GetFileNameWithoutExtension($zipFile).Replace("Backup_Zalo_", "")
        
        Add-Type -AssemblyName Microsoft.VisualBasic
        $newName = [Microsoft.VisualBasic.Interaction]::InputBox("Nhập tên cho profile mới trên máy này:", "Nhập Profile", $defaultName)
        
        if ($newName) {
            $destPath = Join-Path $ProfileRoot $newName
            if (Test-Path $destPath) {
                Show-Msg "Tên profile '$newName' đã tồn tại trên máy này!" "Lỗi" [System.Windows.Forms.MessageBoxIcon]::Error
                return
            }
            
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            Write-Host "Đang khôi phục dữ liệu vào '$newName'..." -ForegroundColor Green
            Expand-Archive -Path $zipFile -DestinationPath $destPath -Force
            
            Show-Msg "Đã khôi phục thành công! Bây giờ bạn có thể dùng ZaloMulti để mở tài khoản '$newName'."
        }
    }
}

# --- MENU CHÍNH ---
$main = New-Object System.Windows.Forms.Form
$main.Text = "ZaloTransfer v1.0 - Truong.it"
$main.Size = New-Object System.Drawing.Size(400, 250)
$main.StartPosition = "CenterScreen"
$main.BackColor = "#f0f2f5"

$btnBackup = New-Object System.Windows.Forms.Button
$btnBackup.Text = "📦 SAO LƯU PROFILE (EXPORT)"
$btnBackup.Size = New-Object System.Drawing.Size(300, 60)
$btnBackup.Location = New-Object System.Drawing.Point(45, 30)
$btnBackup.FlatStyle = "Flat"
$btnBackup.BackColor = "#0068ff"
$btnBackup.ForeColor = "White"
$btnBackup.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnBackup.Add_Click({ Export-ZaloProfile })

$btnRestore = New-Object System.Windows.Forms.Button
$btnRestore.Text = "📥 KHÔI PHỤC PROFILE (IMPORT)"
$btnRestore.Size = New-Object System.Drawing.Size(300, 60)
$btnRestore.Location = New-Object System.Drawing.Point(45, 110)
$btnRestore.FlatStyle = "Flat"
$btnRestore.BackColor = "#28a745"
$btnRestore.ForeColor = "White"
$btnRestore.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnRestore.Add_Click({ Import-ZaloProfile })

$main.Controls.Add($btnBackup)
$main.Controls.Add($btnRestore)
$main.ShowDialog() | Out-Null
