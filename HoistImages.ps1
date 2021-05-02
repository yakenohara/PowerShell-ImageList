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

$str_inDirName = '.'
$str_outFileName = 'images.md'

#変換対象ファイル拡張子
$extCandidates = @(
    ".png",
    ".jpg",
    ".jpeg",
    ".svg"
)

Add-Type -AssemblyName System.Web

#処理対象リスト作成
$list = New-Object System.Collections.Generic.List[System.String]

$pPath = (Split-Path -Parent $MyInvocation.MyCommand.Path) + '\'
Write-Host $pPath

$out_file = New-Object System.IO.StreamWriter(($pPath + $str_outFileName), $false)

Get-ChildItem  -Recurse -Force -Path $str_inDirName | ForEach-Object {
    $list.Add($_.FullName)
}

#変数宣言
$int_numOfFailed = 0

#変換ループ
foreach ($path in $list) {

    if ( -Not (Test-Path $path -PathType container)) { #ファイルの場合
        
        $nowExt = [System.IO.Path]::GetExtension($path) #拡張子文字列を取得
        
        $bool_haveToCopy = $FALSE # コピー必要かどうか
        
        # 対象拡張子かどうかチェック
        foreach ($extCandidate in $extCandidates) {
            if ($extCandidate -eq $nowExt) { # 対象拡張子の時
                $bool_haveToCopy = $TRUE # `コピーする` を設定
                break
            }
        }
        
        if ($bool_haveToCopy) { # コピーする場合
            
            Write-Host $path

            $convertedText = $path.Replace($pPath, '')
            
            # `\` -> `/` に変換
            $convertedText = $convertedText.Replace('\', '/')

            # パーセントエンコーディング
            #$convertedText = [System.Web.HttpUtility]::UrlEncode($convertedText)
            $convertedText = $convertedText.Replace(' ', '%20')

            $convertedText = '![](' + $convertedText + ')  '

            #Write-Host $convertedText
            $out_file.WriteLine($convertedText)
            $out_file.WriteLine('```')
            $out_file.WriteLine($convertedText)
            $out_file.WriteLine('explorer /select,"' + $path + '"')
            $out_file.WriteLine('```')
            
            
        } else { # `コピーしない` の場合
            # nothing to do

        }
    
    } else { #ファイルではない場合
        # nothing to do
    }
}

$out_file.close()

Write-Host ""
Write-Host "Done!"