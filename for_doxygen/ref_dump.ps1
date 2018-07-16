# Doxygenの結合XMLから関数からの参照情報を出力する
# 引数: Doxygenの結合XML
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$xml_path
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
$xml_path = (Convert-Path $xml_path)
[string]$xslt_path = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, ".xslt")
[string]$out_path = [System.IO.Path]::ChangeExtension($xml_path, "ref.tsv")

# 存在チェック
if (-not (Test-Path $xslt_path)) {
    Write-Host ("Error File Not Found: " + $xslt_path) -ForegroundColor red
    Exit -1
}

# 結合
# XSLT読み込み
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
$xslt_setting = New-Object System.Xml.Xsl.XsltSettings
$xslt_setting.EnableDocumentFunction = $true
$xslt_setting.EnableScript = $true
$xslt.Load($xslt_path, $xslt_setting, $null)
# 変換
$xslt.Transform($xml_path, $out_path)
# 終了
Write-Host ("Complete: " + $out_path) -ForegroundColor green
