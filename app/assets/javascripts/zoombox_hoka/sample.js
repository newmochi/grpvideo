$(function(){
  // ズームできるように設定する
  $("a.zoombox").zoombox({
    // テーマを指定する
    theme : "lightbox",
    // 黒のオーバーレイの不透明度を指定する
    opacity : 0.5,
    // アニメーション処理の時間を指定する
    duration : 1000,
    // アニメーションしながら表示するかどうか
    animation : true,
    // ギャラリーモードを指定する
    gallery : true
  });
});