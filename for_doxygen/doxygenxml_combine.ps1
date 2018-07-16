# DoxygenのXMLを結合する
# 引数: Doxygen結果のxml格納フォルダ
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$xml_dir
)

# お約束
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"
trap {
    $Error | foreach {
        Write-Debug $_.Exception.Message
        Write-Debug $_.InvocationInfo.PositionMessage
    }
    Exit -1
}


#### 処理

# パス準備
$xml_dir = (Convert-Path $xml_dir)
[string]$xslt_path = (Join-Path $xml_dir combine.xslt)
[string]$index_path = (Join-Path $xml_dir index.xml)
[string]$combined_path = ($xml_dir + ".xml")

# 存在チェック
if (-not (Test-Path $xslt_path)) {
    Write-Host ("Error File Not Found: " + $xslt_path) -ForegroundColor red
    Exit -1
}
if (-not (Test-Path $index_path)) {
    Write-Host ("Error File Not Found: " + $index_path) -ForegroundColor red
    Exit -1
}

# 結合
# XSLT読み込み
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
$xslt_setting = New-Object System.Xml.Xsl.XsltSettings
$xslt_setting.EnableDocumentFunction = $true
$xslt_setting.EnableScript = $true
$xslt.Load($xslt_path, $xslt_setting, $null)
# 出力準備
$writer_setting = New-Object System.Xml.XmlWriterSettings
$writer_setting.Indent = $true
$writer = [System.Xml.XmlWriter]::Create($combined_path, $writer_setting)
# 変換
$xslt.Transform($index_path, $writer)
# 終了
$writer.Close()
Write-Host ("Complete Combine: " + $combined_path) -ForegroundColor green

