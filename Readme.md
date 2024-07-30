

# git リポジトリから

以下のリポジトリから \`git clone\` で作業ディレクトリにダウンロードして
ください。なお、以前の SORA-UTSU-NAMI ディレクトリがあった場合は削除し
てからダウンロードしてください。

以下は、macOS で、ダウンロードから３分冊をタイプセットする手順です。
各分冊毎に .pdf が作成された時点で open コマンドで pdf をプレビュー
します。

なお、大賀さんの環境では、\`PATH=$(pwd)/source/BXglyphwiki:$PATH\` は
スキップしても良いです。

    git clone https://github.com/128Mac/SORA-UTSU-NAMI.git
    cd SORA-UTSU-NAMI
    PATH=$(pwd)/source/BXglyphwiki:$PATH
    cd source
    make


# タイプセット


## 基本的なタイプセット方法

タイプセットは cluttex / llmk / make を利用したコマンドベースで検証しています。
TeXworks や TeXshop のタイプセットルールに追加する際の参考になればと思います。


### cluttex

-   コマンドラインイメージ
    
    本システムのタイプセットに必須のオプションは \`--engine uplatex\` と \`--shell-escape\`
    
        cluttex --engine uplatex --shell-escape vol-1-天うつ浪第一

-   利用する主なオプションの説明
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">--engine=uplatex</td>
    <td class="org-left">本システムでは必須（省略系は -e ）</td>
    </tr>
    
    <tr>
    <td class="org-left">--shell-escape</td>
    <td class="org-left">本システムでは必須</td>
    </tr>
    
    <tr>
    <td class="org-left">--output-directory=myout</td>
    <td class="org-left">多数の生成される中間作業ファイル置き場</td>
    </tr>
    
    <tr>
    <td class="org-left">--max-iterations 1</td>
    <td class="org-left">処理時間短縮のためvol-1 vol-2 vol-3 のみ利用</td>
    </tr>
    
    <tr>
    <td class="org-left">--includeonly=NAMEs</td>
    <td class="org-left">vol-1 vol-2 vol-3 の部分タイプセット用</td>
    </tr>
    </tbody>
    </table>

-   \`--includeonly=NAMEs\` について
    
    \`\include\` を利用してタイプセットするよう記述されている各巻ごとの
    vol-1 vol-2 vol-3 は、以下のようにして部分的な処理を行うことができ
    ます。
    
        cluttex --engine uplatex --shell-escape --includeonly=001-1-01-其一 vol-1-天うつ浪第一
    
    複数を対象にするには '--includeonly=001-1-01-其一,002-1-02-其二\`
    のように指定します。
    
    なお、\`\include\` では、その都度改ページが発生しますので vol-all は
    \`\input\` に変更していますので --includeonly オプションは指定しても
    効果はありません。


### llmk

-   コマンドラインイメージ
    
    「llmk と cluttex 連携情報」を設定しておくことによって、以下のような
    コマンドでタイプセットできます。
    
        llmk vol-1-天うつ浪第一

-   llmk と cluttex 連携情報
    
    連携情報は、タイプセットするファイルの先頭に必要な情報を書き込んでお
    きます。
    
        % +++
        % sequence = ["cluttex"]
        % [programs.cluttex]
        % command = "cluttex"
        % opts = [
        % "--engine=uplatex",
        % "--shell-escape"
        % "--output-directory=myout"
        % ]
        % +++

-   \`\includeonly\` をコマンドラインからは今の所指定できません。


### make

> この項は、windows で make 関連プログラムをインストールしていないと利用
> できません。

LaTeX 環境でタイプセットが必要な条件は、成果物である .pdf は、素材であ
る .tex や .sty のファイル作成日付より古い場合です。

このルールを Makefile に記述することで、対応できるようにしました。

-   第一巻、第二巻、第三巻の .pdf を作成したい
    
    単に \`make\` とするか、 \`make all\` とすることで、第一巻、第二巻、第三巻
    のそれぞれの .pdf を作成されます。
    
    その後、例えば第一巻に属する .tex ファイルを変更した場合に \`make\`す
    ると第一巻の .pdf のみ再作成されます。

-   三分冊のほか全三巻を一冊とした .pdf も作成したい
    
    \`make allall\` としてください。

-   分冊ごとや全三巻を一冊とした .pdf を個別に作成
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <thead>
    <tr>
    <th scope="col" class="org-left">関連ファイルが更新時のみ再作成</th>
    <th scope="col" class="org-left">とにかく再作成</th>
    </tr>
    </thead>
    <tbody>
    <tr>
    <td class="org-left">make vol-1-天うつ浪第一.pdf</td>
    <td class="org-left">make vol-1-天うつ浪第一</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-2-天うつ浪第二.pdf</td>
    <td class="org-left">make vol-2-天うつ浪第二</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-3-天うつ浪第三.pdf</td>
    <td class="org-left">make vol-3-天うつ浪第三</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-all-天うつ浪.pdf</td>
    <td class="org-left">make vol-all-天うつ浪</td>
    </tr>
    </tbody>
    </table>

-   make で作業できること
    
    いろいろな操作が可能ですが、詳しくは make help の結果を参考にしてください。

-   \includeonly 機能を利用したい
    
    > vol-1-天うつ浪第一 vol-2-天うつ浪第二 vol-3-天うつ浪第三 限定機能です。
    
        make -n vol-1-天うつ浪第一 ADDOPTIONS=--includeonly=001-1-01-其一
    
    複数を対象にするには \`ADDOPTIONS=--includeonly=001-1-01-其一,002-1-02-其二\`
    のように連結して指定する。

-   diff-pdf の利用
    
    > pdf の差分をチェックするための diff-pdf を homebrew などで導入すると、
    > 過去の pdf と比較し、修正内容を視覚的にチェックできるようになります。
    
    ただしコマンドラインベースで、今の所以下のものを提供します。
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">make vol-1-天うつ浪第一-diff</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-2-天うつ浪第二-diff</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-3-天うつ浪第三-diff</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-all-天うつ浪-diff</td>
    </tr>
    </tbody>
    </table>
    
    差分を取る都合上、修正前に上記を実行しておく必要があります。

-   デバッグ機能
    
    原本と見比べるため、一行を 28 文字として基本の組版機能を利用している。
    しかし、二重カギ括弧開始の（『）の取り扱いや、行頭行末禁則の取り扱い
    の違いで強制改行をデバッグ行として組み込んだ。また、注目している箇所
    を素早く探し出すため、強制改行をした箇所の頁番号と行番号も表示した。
    
    これを利用するためには、以下のようにする。
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">make vol-all-天うつ浪-debug</td>
    <td class="org-left">&#xa0;</td>
    </tr>
    
    <tr>
    <td class="org-left">make vol-all-天うつ浪-debug-diff</td>
    <td class="org-left">PDF 差分表示のため</td>
    </tr>
    </tbody>
    </table>

-   ファイルのクリーニング
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">make clean</td>
    <td class="org-left">.pdf を削除</td>
    </tr>
    
    <tr>
    <td class="org-left">make clean-myout</td>
    <td class="org-left">myout ディレクトリ以下を削除</td>
    </tr>
    
    <tr>
    <td class="org-left">make clean-mygwi</td>
    <td class="org-left">mygwi ディレクトリ以下を削除</td>
    </tr>
    </tbody>
    </table>
    
    -   clean-mygwi は、時々修正以外の場所で bxglyphwiki による障害が発生
        することがあります。そんな時、 \`make clean-mygwi\` することで、キャッ
        シュした情報を一旦削除することができます。


# 第一次校正作業報告

電子化作業によって入力された内容を、以下の点に注目して第一次の校正作業を実施しました。

-   参照した原本情報について
    
    原本は、「 [長文原稿の入力を省力化、露伴「天うつ浪」のOCRからtextを抽出出來るか?](https://okumuralab.org/tex/mod/forum/discuss.php?d=3656&parent=22787) 」
    の情報を元に、以下の URL を参考にしました。
    
    -   国立国会図書館デジタルコレクション
        -   [幸田露伴 著『天うつ浪』第１巻,春陽堂,明39-40. 国立国会図書館デジタルコレクション](https://dl.ndl.go.jp/pid/887083)
        -   [幸田露伴 著『天うつ浪』第２巻,春陽堂,明39-40. 国立国会図書館デジタルコレクション](https://dl.ndl.go.jp/pid/887084)
        -   [幸田露伴 著『天うつ浪』第３巻,春陽堂,明39-40. 国立国会図書館デジタルコレクション](https://dl.ndl.go.jp/pid/887085)
    -   国書データベース（2024.04.01 から）（旧 国文学研究資料館 )
        -   [国書データベース 天うつ浪 第１巻](https://school.nijl.ac.jp/kindai/CKMR/CKMR-00910#1)
        -   [国書データベース 天うつ浪 第２巻](https://school.nijl.ac.jp/kindai/CKMR/CKMR-00911#1)
        -   [国書データベース 天うつ浪 第３巻](https://school.nijl.ac.jp/kindai/CKMR/CKMR-00912#1)

-   基本は「原本」を基準にしました。
    -   明らかに誤植と思われるものも「原本通り」ですが、一部補完したものも
        あり、その旨極力コメントを付してしてあります。
        -   例えば、会話部分で、会話の終了を示す閉じ二重カギ括弧

-   「〻（二の字点／揺すり点）」のように見える踊り字
    -   第二巻の殆ど、及び、第一巻の一部の平仮名の「踊り字」として利用して
        いるが、大賀さんが「ゝ」としていたものを踏襲
        -   もしも 「〻」あるいは相当の平仮名用踊り字に変換可能なように、コ
            メントで特定できるようにしてあります。

-   親文字２字に対してルビが（計５文字（２文字３文字／３文字２文字））は
    熟語ルビ処理ではなく、分割して、全角空白を前突き出し・後突き出しとし
    て、以下のように調整しています。
    
        \ruby[||j>]{心}{こゝろ}
        \ruby[||j>]{持}{　もち}
        % \ruby{心持}{こゝろ|もち} ← 元々のイメージを保全してあります。

-   同じ親文字でも、数行違いや巻により異なっているケースが多々ありますが、
    「原本通り」を原則としています。
-   熟語ルビ vs グループルビ
    
    第一巻、第二巻では熟語ルビ扱いのものでも、第三巻ではグループルビの
    ような配置になってい流ものがありますが、原本通りにしました。

-   一次校正では、出来るだけ原本と同じ行送りになるようにすることで、行単
    位に見比べられるように調整して行ました。
    -   一行を 28 文字で open\_bracket\_pos hanging\_punctuation はコメント
        アウトした状態で実施
        
            --- vol-all-天うつ浪.tex
            +++ vol-all-天うつ浪-debug.tex
            @@ -27,8 +27,8 @@
             jafontsize                = 12pt          ,
             fontsize                  = 12pt          ,
             %%%%
            -open_bracket_pos          = nibu_tentsuki , % zenkaku_tentsuki zenkakunibbu_nibu
            -hanging_punctuation                       , % 行頭に句読点等の禁則約物を前行に追い込む
            +% open_bracket_pos        = nibu_tentsuki , % zenkaku_tentsuki zenkakunibbu_nibu
            +% hanging_punctuation                     , % 行頭に句読点等の禁則約物を前行に追い込む
             %%%%
             paper                     = a5paper       ,
             %%%%
    
    -   会話の始まる行や、役物などの関係で原本通りの行送りができない場合は、
        デバッグ用の強制改行を挿入
    
    -   この処置による弊害
        -   nibu\_tentsuki にすることで、会話の始まりの二重カギ括弧（『）
            が行頭で吐出してしまうので、原本とは体裁がやや異なる
        -   それにより半文字ズレが生じ、さらに複数の役物がある場合、原本の組
            版と jlreq のそれとの違いにより行送りが異なってしまう
        -   その影響で行末、行頭付近のルビの配置や踊り字の処理があまりよくな
            くなるケースが発生すると思います。→未チェックですので、どうする
            か要相談です。
-   連続する平仮名は意味あるところで分かち書きとし改行を入れています
    -   形態要素処理を行った上の方がよかったのですが、旧仮名使いでもあるの
        で手動で分解しましたので、組版上は影響はないのですが、ソースを見る
        と、時に細切れにワケすぎた嫌いのところがあります。

-   縦書き、右閉じ対応
    -   分冊の三つは、\include を用いていることから、そこで改ページが発生
        しているようで縦書き、右閉じに対応した頁番号やヘッダーの表示になっ
        ているようです。
    -   全三巻を一括でタイプセットする場合は \include を \input に置き換え
        た他、各巻を \chapter で対応しました。この変更に伴い \chapter の開
        始ページを基数ページから始めるよう変更しています。
-   新字と旧字が混在していますが「原本通り」にしています
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">場(5834)</td>
    <td class="org-left">&#xa0;</td>
    <td class="org-left">塲(5872)</td>
    <td class="org-left">&#xa0;</td>
    </tr>
    
    <tr>
    <td class="org-left">姉(59c9)</td>
    <td class="org-left">市</td>
    <td class="org-left">姊(59ca)</td>
    <td class="org-left">&#xa0;</td>
    </tr>
    
    <tr>
    <td class="org-left">婿(5a7f)</td>
    <td class="org-left">女</td>
    <td class="org-left">聟(805f)</td>
    <td class="org-left">知+耳</td>
    </tr>
    
    <tr>
    <td class="org-left">潜(6f5c)</td>
    <td class="org-left">夫夫</td>
    <td class="org-left">潛(6f5b)</td>
    <td class="org-left">先先</td>
    </tr>
    
    <tr>
    <td class="org-left">蓮(84ee)</td>
    <td class="org-left">&#xa0;</td>
    <td class="org-left">蓮(f999)</td>
    <td class="org-left">採用</td>
    </tr>
    </tbody>
    </table>

-   漢数字のルビ
    
    例の読み方以外の読みの漢数字に関しては原本に記されていますが、それ以
    外は文脈を考慮したルビ表記にしました。
    
    -   特に苦慮したのは「四」「七」
        -   赤穂四十七士は通例通り「しじゅうしち」
        -   「四人」や「七人」は「しにん」「しちにん」でなく基本「よにん」
            「ななにん」にしました
            -   少なくとも「しにん」とすると「死人」につながるので私見ですが、
                そうは読ませたくなかったと思います。
        -   でも年齢の話題の箇所の「十七八」は「じふしちはち」かな？「じふな
            なはち」でもいいけど
    -   「十」は状況に応じて「じふ」「とほ」「とを」
    -   「五十」「六十」を時に「いそじ」「むそじ」とも読む場合がありますが、
        「ごじふ」「ろくじふ」にしました。


# チェックしていただきたいこと

-   対象は、分冊毎のものか、全三巻まとめてタイプセットのどちらかで実施してください
-   ざっとと読み返していただき
    -   誤字・誤植・行送り・踊り字表記...等々を気になる点をお知らせください
        -   伝達方法は .pdf に書き込んでいただいても良いです
        -   ソースを修正していただいて diff を送っていただいても良いです。


# 旧字対応検討中

以下の件に関しては、検討中です。
もちろん、ご意見も歓迎します。


## 「古」のように→「ナ」+「口」に「十」を造りの一部にもつ字のグリフ変更

-   舌 ... 要検討
-   苦 ... 要検討
-   故 ... 要検討
-   直 ... 要検討
-   真 ... 要検討 さらにしたの造り「ー」「ハ」→「｜」「ー」「ハ」


## 刀へん「刀」 ネ」

-   グリフ変更検討
    -   初 ... 示刀？


## ころもへんしめすへん「示」 vs 「ネ」

-   unicode 変更検討
    -   [ ] 祕 vs 秘
    -   [ ] 祖 vs 祖
-   unicode 既に対応
    -   [X] 神 vs 神
    -   [X] 祥 vs 祥
    -   [X] 福 vs 福
    -   [X] 社 vs 社
    -   [X] 祈 vs 祈
    -   [X] 祝 vs 祝
    -   [X] 禍 vs 禍
-   該当文字なし
    -   [-] 祿 vs 禄
    -   [-] 祉 vs 祉
    -   [-] 祐 vs 祐
    -   [-] 禎 vs 禎


## 「叱」 「口ヒ」の「ヒ」の「ノ」の扱い

でも「ノ」が「口」の下まで伸びているグリフは見当たらない


## 「巨」の上下の「ー」が左に「｜」を突き出ている

-   (u5de8-t) (=u5de8-h)
-   (u5de8-ue0101) (=aj1-13714) (=dkw-08722) (=jmj-010776) (=zihai-000338) (=u5de8-ue0103) (=koseki-098730) (=hkcs\_u5de8)
-   (u5de8-var-001)

