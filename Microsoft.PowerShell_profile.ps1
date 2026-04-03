[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function run($file) {
    # 拡張子を取得
    $ext = [System.IO.Path]::GetExtension($file)

    # 拡張子に応じて処理を分岐
    if ($ext -eq ".cpp") {
        # 引数を分けて渡す
        g++ -std=c++20 $file
    } else {
        gcc $file
    }

    # コンパイルが成功した場合のみ実行
    if ($LASTEXITCODE -eq 0) {
        ./a.exe
    }
}

function c {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputFile
    )

    # 入力ファイル存在チェック
    if (-not (Test-Path $InputFile)) {
        Write-Host "Error: $InputFile が見つかりません。" -ForegroundColor Red
        return
    }

    # 拡張子取得
    $ext = [System.IO.Path]::GetExtension($InputFile).ToLower()

    # txt の場合は .c を生成する
    if ($ext -eq ".txt") {

        # 出力ファイル名（.c に変換）
        $OutputFile = [System.IO.Path]::ChangeExtension($InputFile, ".c")

        # 前半（固定）
        $before = @"
#include <stdio.h>
#include <stdlib.h>
int main(void)

"@

        # 本文読み込み
        $body = Get-Content $InputFile -Raw

        # 結合して .c を生成
        $before + $body | Set-Content $OutputFile -Encoding UTF8

        # run を呼び出す
        run $OutputFile
        return
    }

    # txt 以外はそのまま run に渡す
    run $InputFile
}

function New-SourceFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    # 拡張子が無ければ .c を付ける
    if (-not $Name.Contains(".")) {
        $Name = "$Name.c"
    }

    $ext = [System.IO.Path]::GetExtension($Name).ToLower()

    if (Test-Path $Name) {
        Write-Host "Error: '$Name' はすでに存在します。" -ForegroundColor Red
        return
    }

    switch ($ext) {
        ".c" {
            $template = @"
#include <stdio.h>

int main(void)
{
    

    return 0;
}
"@
        }
        ".cpp" {
            $template = @"
#include <iostream>
using namespace std;

int main()
{
    

    return 0;
}
"@
        }
        default {
            Write-Host "未対応の拡張子です: $ext" -ForegroundColor Yellow
            return
        }
    }

    Set-Content -Path $Name -Value $template -Encoding UTF8
    Write-Host "Created $Name" -ForegroundColor Green
}

Set-Alias new New-SourceFile
