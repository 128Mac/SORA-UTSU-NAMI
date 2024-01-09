#!/usr/bin/env ruby

BEGIN {

  濁点？=[
    *('が'..'ぢ').step(2),
    *('づ'..'ど').step(2),
    *('ば'..'ぼ').step(3),
    'ゔ',
  ].join

  半濁点？=[
    *('ぱ'..'ぽ').step(3),
  ].join

  小書き文字？=[
    *('ぁ'..'ぉ').step(2),
    'っ',
    *('ゃ'..'ょ').step(2),
    'ゎ',
  ].join

  静音以外？ = [
    濁点？, 半濁点？, 小書き文字？,
  ].join

  静音？ = [
    *('あ'..'ゔ')
  ].join.gsub!(/[#{小書き文字？}]/, "")
  ##p 濁点？
  ##p 半濁点？
  ##p 小書き文字？
  ##p 静音？

  静音？.each_char{ |c|
    繰り返し文字 = 濁点？.include?(c) ? 'ゞ' : 'ゝ'

    unless 半濁点？.include?(c) ; then
      printf "(%s[|]*)%s => \\1%s\n", c, c, 繰り返し文字
    end
    if 濁点？.include?(c.succ) ; then
      printf "(%s[|]*)%s => \\1ゞ\n", c, c.succ
    end
  }
}
