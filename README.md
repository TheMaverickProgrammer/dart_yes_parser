<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

YES Script - **Y**our **E**xtensible **S**cript is a meta scriptlet standard
where elements and their meaning are determined by **YOU** the programmer.
They can be extended further by use of attributes which allow **YOUR**
end-users to make their additions to **YOUR** elements.

## YES Spec
### Elements
Each line represents **one** element. 
Elements have a `name` and zero or more `keyvalue`s.

Elements can be one of 4 types:
1. Global - Begins with the `!` symbol. This element affects the whole doc.
2. Attribute - Begins with the `@` symbol. This element affects the next _standard_ element.
3. Standard - Begins with any other symbol not reserved by YES spec. These are **your** own elements.
4. Comment - Begins with `#` symbol. The entire line is parsed as read-only text without keyvalues.

#### Examples
Consider this scene config file witten with YES script `intro.cts`:
```rust
# This element is a comment.
# This file represent the intro animation for this app.

# Globals begin with `!` and can be placed anywhere in the doc
# but are easier to find at the very top.
# This music element can be used to play music for this scene.
!music "path/to/music.mp3" loop=true
!character Billy
!character Alice

# These are standard elements and can be interpreted by
# a program or other format using the YES spec.
Billy "hello, how are you today?"
Alice "I'm doing well!"
move Billy x=200 y=300

# Attributes begin with `@` and can add extra meta elements
# to the next standard element. They can be stacked.
@emote SMILE
@play_sound "charm.wav"
Billy "Good to hear it!"

wait 5s

# etc
```

### Keyvalues
Keyvalues represent a `key` and a `value`. If elements are functions, keyvalues
are like arguments.

`fadeout 5s color=white`

In traditional programming languages, this is equivalent to:

`fadeout(seconds(5), Colors.white)`

Keys and values can be any data type because they are stored internally as a
string and parsed how the end-user needs them.

For string literals, keys and values can be enclosed in quotes `""`.

#### Nameless keys
For keys that do not have names, like an arbitrary list size, nameless keys can be used.

Consider this scriplet:
```rust
# Declare a list called "x" with the remaining elements
list name = x, 5, 4, 3, 2, 1
print x
```

Because nameless keys have no name, the values in an element cannot be fetched by
key. Instead, you will need to loop through the keyvalues yourself to determine
how to process them.

### Delimiters
Every element follows this format:

`<SYMBOL?><NAME><KEYVALUES?>`

e.g.

`@foo answer_to_life=42`

For user convenience, the parser intelligently scans ahead for white spaces.
This is also valid:

`   @    foo answer_to_life = 42`

In order to properly parse multipe keyvalues, the parser must make a distinction
between to beginning and end of additional consequtive tokens.

The following are the only allowed delimiter characters:
* `spaceOnly` or ` ` the blank character
* `spaceComma` or `,` the comma character

Therefore, the parser can also handle the following example:

`! file_path "path/to/file", x=128, y = 256, antialias`

Without comma delimiters, the key `y` would incorrectly map to the value `=`.

### Grammar
Rules with `?` represent an optional token.
Rules with `+` represent one _or_ more.
Rule **__S__** represents any character.
Rule **__S'__** represents any non-reserved character.
Rule **__0__** represents newline character(s).

The grammar root begins with `<LINE>`.
* `<LINE>` -> `<ELEMENT><NL>?`
* `<NL>` -> **__0__**
* `<ELEMENT>` -> `<SYMBOL>?<NAME><KEYVALUE>?+`
* `<SYMBOL>` -> `<GLOBAL>` | `<ATTRIBUTE> ` | `<COMMENT>`
* `<GLOBAL>` -> `!`
* `<ATTRIBUTE>` -> `@`
* `<COMMENT>` -> `#`
* `<NAME>` -> **__S'__**
* `<KEYVALUE>` -> `<VALUE><DELIMITER>?` | `<KEY>=<VALUE><DELIMITER>`
* `<DELIMITER>` -> ` ` | `,`
* `<KEY>` -> `<RAWTOKEN>`
* `<VALUE>` -> `<RAWTOKEN>`
* `<RAWTOKEN>` -> `<TOKEN>` | `"<TOKEN>"`
* `<TOKEN>` -> **__S__**

#### Reserved Characters
The following characters are used in YES spec and **cannot** be
used for element names:
1. `!`
2. `#`
3. `@`
4. `,`

If these characters are sounded by quotes (see `<RAWTOKEN>` generation),
then these characters can be safely used.

## Getting started
TODO