# clox - Lox バイトコード仮想マシン

Lox言語のバイトコードVM実装。C言語で書かれた高速なインタプリタです。

## 概要

cloxは、Bob Nystromの著書「Crafting Interpreters」に基づいて実装されたLox言語のバイトコード仮想マシンです。シングルパス・ワンパスコンパイラでソースコードをバイトコードに変換し、スタックベースの仮想マシンで実行します。

## 特徴

- **バイトコードコンパイル**: Loxソースコードを効率的なバイトコード命令に変換
- **スタックベースVM**: シンプルで高速なスタックマシンアーキテクチャ
- **ガベージコレクション**: Mark & Sweepアルゴリズムによる自動メモリ管理
- **クロージャ**: 第一級関数とレキシカルスコープのサポート
- **クラスとオブジェクト**: クラスベースのオブジェクト指向プログラミング
- **継承**: シングル継承とスーパークラスメソッドへのアクセス

## ビルド方法

```bash
# コンパイル
make

# ビルド成果物のクリーンアップ
make clean

# クリーン + リビルド
make rebuild
```

## 使い方

### REPLモード（対話モード）

```bash
./clox
```

### スクリプトファイルの実行

```bash
./clox script.lox
```

## Lox言語仕様

### データ型

```lox
// 数値
var a = 1;
var b = 2.5;

// 文字列
var name = "clox";
var message = "Hello, " + "World!";

// ブール値
var isTrue = true;
var isFalse = false;

// nil（null相当）
var nothing = nil;
```

### 変数

```lox
// グローバル変数
var global = "I am global";

// ローカル変数
{
    var local = "I am local";
    print local;  // OK
}
// print local;  // エラー: スコープ外
```

### 制御構文

```lox
// if文
if (condition) {
    print "true branch";
} else {
    print "false branch";
}

// while文
var i = 0;
while (i < 10) {
    print i;
    i = i + 1;
}

// for文
for (var i = 0; i < 10; i = i + 1) {
    print i;
}

// continue文
for (var i = 0; i < 10; i = i + 1) {
    if (i == 5) continue;
    print i;
}
```

### 関数

```lox
// 関数定義
fun greet(name) {
    return "Hello, " + name + "!";
}

print greet("World");  // "Hello, World!"

// 再帰関数
fun fib(n) {
    if (n <= 1) return n;
    return fib(n - 2) + fib(n - 1);
}

print fib(10);  // 55
```

### クロージャ

```lox
// 外側のスコープの変数をキャプチャ
fun makeCounter() {
    var count = 0;
    fun increment() {
        count = count + 1;
        return count;
    }
    return increment;
}

var counter = makeCounter();
print counter();  // 1
print counter();  // 2
print counter();  // 3
```

### クラスとオブジェクト

```lox
// クラス定義
class CoffeeMaker {
    init(coffee) {
        this.coffee = coffee;
    }

    brew() {
        print "Brewing " + this.coffee;
    }
}

// インスタンス作成
var maker = CoffeeMaker("Espresso");
maker.brew();  // "Brewing Espresso"

// プロパティアクセス
maker.coffee = "Latte";
print maker.coffee;  // "Latte"
```

### 継承

```lox
class Doughnut {
    cook() {
        print "Dunk in the fryer.";
        this.finish("sprinkles");
    }

    finish(ingredient) {
        print "Adding " + ingredient;
    }
}

class Cruller < Doughnut {
    finish(ingredient) {
        // スーパークラスのメソッドをオーバーライド
        print "Glazing with " + ingredient;
    }
}

var cruller = Cruller();
cruller.cook();
// "Dunk in the fryer."
// "Glazing with sprinkles"
```

### 組み込み関数

```lox
// clock() - 現在時刻を秒単位で返す
var start = clock();
// ... 処理 ...
var elapsed = clock() - start;
print "Elapsed: " + elapsed;
```

## アーキテクチャ

### コンポーネント

- **Scanner (scanner.c)**: ソースコードをトークンに分解
- **Compiler (compiler.c)**: トークンをバイトコードにコンパイル
- **VM (vm.c)**: バイトコードを実行する仮想マシン
- **Chunk (chunk.c)**: バイトコード命令列の管理
- **Value (value.c)**: 動的型付けされた値の表現
- **Object (object.c)**: ヒープ割り当てオブジェクトの管理
- **Table (table.c)**: ハッシュテーブル実装
- **Memory (memory.c)**: メモリ管理とガベージコレクション

### バイトコード命令

主要な命令セット:
- `OP_CONSTANT`: 定数をスタックにプッシュ
- `OP_ADD`, `OP_SUBTRACT`, `OP_MULTIPLY`, `OP_DIVIDE`: 算術演算
- `OP_GET_LOCAL`, `OP_SET_LOCAL`: ローカル変数アクセス
- `OP_GET_GLOBAL`, `OP_SET_GLOBAL`: グローバル変数アクセス
- `OP_GET_UPVALUE`, `OP_SET_UPVALUE`: クロージャ変数アクセス
- `OP_CALL`: 関数呼び出し
- `OP_CLOSURE`: クロージャ作成
- `OP_CLASS`: クラス定義
- `OP_GET_PROPERTY`, `OP_SET_PROPERTY`: プロパティアクセス
- `OP_INVOKE`: メソッド呼び出し最適化
- `OP_JUMP`, `OP_JUMP_IF_FALSE`, `OP_LOOP`: 制御フロー

### ガベージコレクション

Mark & Sweep方式を採用:
1. **Mark Phase**: VMスタック、グローバル変数、コンパイラから到達可能なオブジェクトをマーク
2. **Sweep Phase**: マークされていないオブジェクトを解放
3. トリガー: ヒープサイズが閾値を超えた時に自動実行

### ローカル変数の実装

コンパイル時に各ローカル変数にスロット番号を割り当て:
- スロット0: 関数オブジェクト自体（メソッドの場合は`this`）
- スロット1〜: パラメータとローカル変数
- 実行時は配列インデックスで高速アクセス

### アップバリュー（クロージャ）の仕組み

2段階のキャプチャ:
- **直接キャプチャ (`isLocal=true`)**: 親のローカル変数を直接参照
- **間接キャプチャ (`isLocal=false`)**: 親のアップバリューを共有

これにより任意の深さのネストした関数から外側の変数にアクセス可能。

## プロジェクト構造

```
clox/
├── src/
│   └── main.c              # エントリーポイント
├── include/
│   ├── chunk.c/h           # バイトコードチャンク
│   ├── compiler.c/h        # コンパイラ
│   ├── debug.c/h           # デバッグ・逆アセンブラ
│   ├── memory.c/h          # メモリ管理・GC
│   ├── object.c/h          # オブジェクトシステム
│   ├── scanner.c/h         # 字句解析
│   ├── table.c/h           # ハッシュテーブル
│   ├── value.c/h           # 値の表現
│   └── vm.c/h              # 仮想マシン
├── *.lox                   # テストスクリプト
├── Makefile
└── README.md
```

## テストファイル

- `test.lox`: フィボナッチ数列とベンチマーク
- `class_test.lox`: クラスと継承のテスト
- `gc_test.lox`: ガベージコレクションのテスト
- `hash_test.lox`: ハッシュテーブルのテスト

## デバッグ

コンパイル時のデバッグフラグ（compiler.c, vm.c）:
- `DEBUG_PRINT_CODE`: コンパイル後のバイトコードを出力
- `DEBUG_TRACE_EXECUTION`: 実行中の各命令とスタック状態を表示
- `DEBUG_LOG_GC`: GCのログを出力

## 実装の詳細

### オブジェクトの継承（疑似継承）

C言語で継承を実現するため、構造体の最初のメンバーを共通の`Obj`型にする技法を使用:

```c
// 基底型
struct Obj {
    ObjType type;
    bool isMarked;
    struct Obj *next;
};

// 派生型
struct ObjString {
    Obj obj;      // 最初のメンバー
    int length;
    char *chars;
    uint32_t hash;
};
```

構造体の最初のメンバーのアドレスは構造体全体のアドレスと同じため、`ObjString*` ⇄ `Obj*` のキャストが安全に可能。

### コールフレーム

関数呼び出しは `CallFrame` の配列で管理:
- `frame->closure`: 実行中のクロージャ
- `frame->ip`: 命令ポインタ（次に実行する命令）
- `frame->slots`: このフレームのスタックスロットの開始位置

### バウンドメソッド

メソッドをファーストクラス値として扱うため、レシーバとメソッドをペアにした`ObjBoundMethod`を使用:
```c
typedef struct {
    Obj obj;
    Value receiver;      // レシーバ（インスタンス）
    ObjClosure *method;  // メソッド
} ObjBoundMethod;
```

呼び出し時にレシーバをスロット0に配置してメソッドを実行。

## 参考文献

- [Crafting Interpreters](https://craftinginterpreters.com/) by Bob Nystrom
- 特に Part III: A Bytecode Virtual Machine


## 開発履歴

- Mark & Sweep ガベージコレクション実装
- クロージャのサポート
- 制御構文（if, while, for, continue）追加
- 仮想マシンとコンパイラのコア機能実装
