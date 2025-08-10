
# 检查是否提供了可执行文件路径参数
if ($args.Count -eq 0) {
    Write-Error "请提供可执行文件的路径作为参数"
    Write-Host "用法: .\run.ps1 <可执行文件路径>"
    exit 1
}

# 获取可执行文件路径
$exePath = $args[0]

# 检查可执行文件是否存在
if (-not (Test-Path -Path $exePath -PathType Leaf)) {
    Write-Error "可执行文件不存在: $exePath"
    exit 1
}

# 获取可执行文件所在的目录
$exeDir = Split-Path -Path $exePath -Parent

# 定义输入输出文件所在目录（与可执行文件同目录）
$inputDir = $exeDir
$outputDir = $exeDir

# 获取所有以.in为扩展名的输入文件（按名称排序）
$inputFiles = Get-ChildItem -Path $inputDir -Filter "*.in" -File | Sort-Object Name

# 检查是否有输入文件
if ($inputFiles.Count -eq 0) {
    Write-Host "在可执行文件目录 $inputDir 中没有找到以.in为扩展名的文件" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($inputFiles.Count) 个输入文件，开始处理..." -ForegroundColor Cyan

# 处理每个输入文件
for ($i = 0; $i -lt $inputFiles.Count; $i++) {
    $fileNumber = $i + 1
    $currentFile = $inputFiles[$i]
    # 直接读取文件内容，不做额外处理
    $currentInput = Get-Content -Path $currentFile.FullName -Raw -Encoding UTF8

    # 生成对应的输出文件路径（xxx.in -> xxx.out）
    $outputFileName = [System.IO.Path]::ChangeExtension($currentFile.Name, ".out")
    $outputFile = Join-Path -Path $outputDir -ChildPath $outputFileName

    Write-Host "`n===== 处理第 $fileNumber 个文件: $($currentFile.Name) =====" -ForegroundColor Cyan
    Write-Host "输入内容:"
    Write-Host $currentInput
    Write-Host "`n输出结果:" -ForegroundColor Green

    # 将当前文件内容作为标准输入传递给可执行文件
    $output = & { echo $currentInput | & $exePath 2>&1 }

    # 显示输出到控制台
    $output | Out-Host

    # 写入输出到对应的输出文件（使用UTF-8编码）
    $output | Out-File -FilePath $outputFile -Encoding UTF8 -Force

    Write-Host "输出已保存到: $outputFile" -ForegroundColor Yellow
}

Write-Host "`n所有输入文件处理完成。" -ForegroundColor Green
