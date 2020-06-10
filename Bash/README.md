
## 自分用の規約

### -n で参照する場合、名前は絶対に同じにならない様にする

参考記事
http://mywiki.wooledge.org/BashFAQ/048#line-120

だめな例

```sh
func1() {
    local -n a=$1; # warning: a: circular name reference
}
func2() {
    local -n a=$1;
    func1 a
}
arr=()
func2 arr
```

上記の問題を回避する為に、変数名の先頭に `__関数名_` を付与する<br>
(もちろんこんな事はしたくない！)

```sh
func1() {
    local -n __func1_a=$1;
}
func2() {
    local -n __func2_a=$1;
    func1 __func2_a
}
arr=()
func2 arr
```