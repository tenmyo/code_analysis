# Doxygen�̌���XML����֐�����̎Q�Ə����o�͂���
# ����: Doxygen�̌���XML
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$xml_path
)

# ����
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


#### ����

# �p�X����
$xml_path = (Convert-Path $xml_path)
[string]$xslt_path = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, ".xslt")
[string]$out_path = [System.IO.Path]::ChangeExtension($xml_path, "ref.tsv")

# ���݃`�F�b�N
if (-not (Test-Path $xslt_path)) {
    Write-Host ("Error File Not Found: " + $xslt_path) -ForegroundColor red
    Exit -1
}

# ����
# XSLT�ǂݍ���
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
$xslt_setting = New-Object System.Xml.Xsl.XsltSettings
$xslt_setting.EnableDocumentFunction = $true
$xslt_setting.EnableScript = $true
$xslt.Load($xslt_path, $xslt_setting, $null)
# �ϊ�
$xslt.Transform($xml_path, $out_path)
# �I��
Write-Host ("Complete: " + $out_path) -ForegroundColor green
