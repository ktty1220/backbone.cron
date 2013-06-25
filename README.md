# Backbone.Cron - Backbone.jsにcron機能を実装するクラス

Backbone.jsの各オブジェクトにcronによる時間指定でメソッドを実行する機能を仕込むことができます。

定期的に`fetch()`させたいけど`setInterval()`だとちょっと物足りない場合などにどうぞ。

## 使い方

backbone.cron.jsをbackbone.jsの後にロードしてください。

    <script type="text/javascript" src="/path/to/backbone.js"></script>
    <script type="text/javascript" src="backbone.cron.js"></script>

`Backbone.～.extend`の`initialize()`でBackbone.Cronオブジェクトを作成します。

### モデルにcronを仕込む例

    var HogeModel = Backbone.Model.extend({
      initialize: function () {
        this.cron = new Backbone.Cron(this, {
          test1: '0,45,20-23 * * * * * test1',
          test2: '39 */6,10,20,40,50 * * * * test2',
          test3: '0 */5 */2 * * * test2'
        });
      },

      test1: function (label, now) {
        console.log(label, now);
      },

      test2: function (label, now) {
        console.log(label, now);
      }
    });

## メソッド

### new Backbone.Cron(&lt;関連付けるオブジェクト&gt;, &lt;crontab設定&gt;[, 自動スタート設定]);

##### 引数1: 関連付けるオブジェクト

引数2のcrontabで指定したメソッドを実行させるオブジェクトです。大抵の場合は`this`で良いと思います(上記の例では`this` = HogeModelオブジェクト)。

##### 引数2: crontab設定

`ラベル`:`crontab`のペアからなる連想配列を指定します。crontabは

`秒` `分` `時` `日` `月` `曜日` `実行するメソッド`

の順に半角スペース区切りで指定します。一通りのcrontab書式が指定可能です。

ここで指定したメソッドが呼び出される時には(`ラベル`、`現在日時のDateオブジェクト`)の2つが引数で渡されます。

##### 引数3: 自動スタート設定

デフォルトではBackbone.Cronをnewした時点でタイマーが作動します。とりあえずnewはするけど実行はちょっと後でという場合には`false`を指定してください。そして必要になったら`start()`メソッドでタイマーを作動させてください。

### start()

作成したBackbone.Cronオブジェクトのタイマーを作動させます。

### stop()

Backbone.Cronオブジェクトのタイマーを停止させます。crontabで登録した全ての処理がストップされます。

### off(&lt;ラベル&gt;)

指定したラベルの処理だけ実行させないようにします。

### on(&lt;ラベル&gt;)

`off()`で止めたラベルの処理を再度実行させるようにします。

## 注意点

Backbone.Cronを仕込んだオブジェクトを削除する前には必ず`stop()`メソッドでタイマーを止めてください。そうしないとオブジェクトを削除した後にもタイマー処理が動き続け、メモリリークが発生します。

なお、Backbone.Cronの内部では、`remove`イベントで`stop()`が発生するようにbindしているので、Backbone.Modelに関連付けられたBackbone.Cronオブジェクトに関しては、Model削除時に自動的にタイマーが停止されます。

ただし、`Collection.reset()`の場合、(Backbone.jsバージョン1.0.0の段階では)Modelに対して`remove`イベントが発生しないのでタイマーが停止されません。そこで、Backbone.Collection.extendで`reset()`の処理を以下の様に拡張しておけば、`reset()`時に`remove`イベントが発火されるようになります。

### Backbone.Collectionのreset()を拡張

    var HogeCollection = Backbone.Collection.extend({
      model: HogeModel,

      reset: function (models, options) {
        this.each(function (model) {
          model.trigger('remove');
        });
        return HogeCollection.__super__.reset.apply(this, arguments);
      },

## 最後に

Backbone.jsに特化しているのは`remove`イベントのbindだけなので、この部分を潰せばBackbone.jsに限らず、色々なオブジェクトにCron処理を実装する事ができます(underscore.js依存ですが)。

ちなみにモダンブラウザとIE7以上で動作確認済みです。
