# <License>------------------------------------------------------------

#  Copyright (c) 2021 Shinnosuke Yakenohara

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# -----------------------------------------------------------</License>


# <Settings>----------------------------------------------------------------
$str_outFileName = 'Image List.md'

# 画像ファイル拡張子
$extCandidates = @(
    '*.png',
    '*.jpg',
    '*.jpeg',
    '*.gif',
    '*.svg'
)
$enc_name = "utf-8" # 出力ファイルのテキストエンコード
# ---------------------------------------------------------------</Settings>

# Argument check
if ($Args.count -lt 1){
    Write-Error ("[error] directory not specified.")
    return
}

# 検索対象となる `System.IO.FileInfo` オブジェクトリストを作成
$fInfos = 
    Get-ChildItem -Path $Args[0] -Recurse -File -Include $extCandidates | # 指定ファイル名で `System.IO.FileInfo` オブジェクトリストを取得
    Sort-Object -Property FullName # フルパスの名称で sort

# 対象件数が 0 だった場合は終了
if ($fInfos -eq $null){ # 対象件数が 0 だった場合
    Write-Host 'Image file not found.'
    return
}

# 出力先ファイル StreamWriter を開く
try{
    $enc_obj = [Text.Encoding]::GetEncoding($enc_name)
    
    if ($enc_obj.CodePage -eq 65001){ # for utf-8 encoding with no BOM
        $outFileWriter = New-Object System.IO.StreamWriter($str_outFileName, $false)
        
    } else {
        $outFileWriter = New-Object System.IO.StreamWriter($str_outFileName, $false, $enc_obj)
    }
    
} catch { # 出力先ファイル StreamWriter を開けなかった場合
    Write-Error ("[error] " + $_.Exception.Message)
    try{
        $outFileWriter.Close()
    } catch {}
    return
}

$pPath = (Split-Path -Parent $MyInvocation.MyCommand.Path) + '\'

for ($idx = 0 ; $idx -lt $fInfos.count ; $idx++){
    
    Write-Host "($($idx + 1) of $($fInfos.count)) $($fInfos[$idx].FullName)"
    
    # <markdown 書式 `![ ]( )` 文字列の生成>--------------------------------------------------

    $str_mdStyle = $fInfos[$idx].FullName.Replace($pPath, '')
    $str_mdStyle = $str_mdStyle.Replace('\', '/')
    
    #
    # パーセントエンコーディング
    # 
    # note
    # markdown の仕様なのか、日本語は日本語のままで OK なので、` ` (スペース) のみ `%20` に変換する
    # 
    $str_mdStyle = $str_mdStyle.Replace(' ', '%20')
    $str_mdStyle = '![](' + $str_mdStyle + ')  '

    # -------------------------------------------------</markdown 書式 `![ ]( )` 文字列の生成>

    # <Run command `explorer /select," "` 文字列の生成>---------------------------------------

    $str_runCommand = "explorer /select,`"$($fInfos[$idx].FullName)`""

    # --------------------------------------</Run command `explorer /select," "` 文字列の生成>

    # Write
    $outFileWriter.WriteLine($str_mdStyle)
    $outFileWriter.WriteLine('```')
    $outFileWriter.WriteLine($str_mdStyle)
    $outFileWriter.WriteLine($str_runCommand)
    $outFileWriter.WriteLine('```')

}

# file close
$outFileWriter.Close()

Write-Host ""
Write-Host "Done!"
