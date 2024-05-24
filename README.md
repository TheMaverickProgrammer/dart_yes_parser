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
# `YES` Script
`YES` - **Y**our **E**xtensible **S**cript is a meta scriptlet standard\
whose elements and their meaning are determined by **YOU** the programmer.\
They can be extended further by use of attributes which allow **YOUR**\
end-users to make their additions to **YOUR** elements.

- [`YES` Script](#yes-script)
  - [License](#license)
  - [Specification](#specification)
    - [Elements](#elements)
      - [Examples](#examples)
    - [Keyvalues](#keyvalues)
      - [Nameless keys](#nameless-keys)
    - [Attributes](#attributes)
      - [Multiple attributes](#multiple-attributes)
    - [Delimiters](#delimiters)
    - [Grammar](#grammar)
      - [Reserved Characters](#reserved-characters)
- [Getting Started](#getting-started)

## License
This project is licensed under the [Common Development and Distribution License (CDDL)](https://github.com/TheMaverickProgrammer/dart_yes_parser/blob/master/legal/LICENSE.md). 

## Specification
### Elements
Each line represents **one** element. 
Elements have a `name` and zero or more `keyvalue`s.

Elements can be one of 4 types:
1. Global - Begins with the `!` symbol. This element affects the whole doc.
2. Attribute - Begins with the `@` symbol. This element affects the next
    _standard_ element.
3. Standard - Begins with any other symbol not reserved by YES spec. These
    are **YOUR** own elements.
4. Comment - Begins with `#` symbol. The entire line is parsed as read-only
    text without keyvalues.

#### Examples
Consider this scene config file witten with YES script `intro.cts`:
```r
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
Keyvalues represent a `key` and a `value`.\
If your elements are like functions, then keyvalues are like arguments.\
If your elements are like objects, then keyvalues are like fields.

`fadeout 5s color=white`

In traditional programming languages, this is equivalent to:

`fadeout(seconds(5), Colors.white)`

or even

`let fadeout = {seconds: 5, color: white}`

Keys and values can be any data type because they are stored internally as a\
string and parsed how the end-user needs them.

For string literals, keys and values can be enclosed in quotes `""`.

#### Nameless keys
For keys that do not have names, like an arbitrary list size, nameless keys\
can be used.

Consider this scriplet:
```r
# Declare a list called "x" with the remaining elements
list name = x, 5, 4, 3, 2, 1
print x
```

Because nameless keys have no name, the values in an element cannot be fetched\
by key. Instead, you will need to loop through the keyvalues yourself to\
determine how to process them.

### Attributes
Attributes are elements that embed themselves in the next standard element.
In otherwords, they can be stacked. Attributes provide meta-behavior which\
you can optionally support in your own elements.

Consider this scriplet:
```r
!image_path "game/resources/my_hero.png"

anim runcyle
frame dur=5f x=120 y=300 w=32 h=32 originx=16 originy=16
frame dur=5f x=152 y=300 w=32 h=32 originx=10 originy=16
frame dur=5f x=184 y=300 w=32 h=32 originx=5 originy=16
```

In this above example, we have an animation with 3 keyframes.\
The animation format described by the elements above have a shifting origin xy.\
Calculating the local origin relative to each frame's start xy can be hard for\
your end-users. Entering the pixel-coordinate would be easier.

We can support an optional attribute `coords` to provide to the parser\
extra data (meta) inside of the next standard element `anim`.

```r
!image_path "game/resources/my_hero.png"

# Adds an attribute to the next element `anim`
@coords global
anim runcyle
frame dur=5f x=120 y=300 w=32 h=32 originx=136 originy=316
frame dur=5f x=152 y=300 w=32 h=32 originx=182 originy=316
frame dur=5f x=184 y=300 w=32 h=32 originx=192 originy=316
```

If we inspect `anim`'s attribute field, we will find `coords` with a nameless\
key whose value is `global` and from this information we can elect to\
interpret the origin xy points using coordinate relative to the entire\
spritesheet `my_hero.png` instead. This creates convenience for those\
end-users who want to make animation edits quicker.

#### Multiple attributes
Recall that attributes stack allowing for more custom behavior:
```r
!image_path "game/resources/my_hero.png"

# Adds 2 attributes to the upcoming standard element `anim`
@coords global
@loop true
anim runcyle
frame dur=5f x=120 y=300 w=32 h=32 originx=136 originy=316
...
```

If we inspect this `anim`'s attributes now, we'll see two: `coords` + `loop`.

### Delimiters
Every element can be generated by this [production rule](#grammar):

`<SYMBOL><NAME><KEYVALUE>`

e.g.

`@foo answer_to_life=42`

For user convenience, the parser intelligently scans ahead for white spaces.\
This is also valid:

`   @    foo answer_to_life = 42`

In order to properly parse multipe keyvalues, the parser must make a\
distinction between to beginning and end of additional consequtive tokens.

The following are the only allowed delimiter characters:
* `spaceOnly` or ` ` the blank character
* `spaceComma` or `,` the comma character

Therefore, the parser can also handle the following example:

`! file_path "path/to/file", x=128, y = 256, antialias`

Without comma delimiters, the key `y` would incorrectly map to the value `=`.

### Grammar
Production rule **__s__** represents any character.\
Production rule **__s'__** represents any non-reserved character.\
Production rule **__ϵ__** generates the empty set (no character).\
The grammar root begins with `<ELEMENT>`.

* `<ELEMENT>` → `<SYMBOL><NAME><KEYVALUE>`
* `<SYMBOL>` → `<GLOBAL>` | `<ATTRIBUTE> ` | `<COMMENT>` | **__ϵ__**
* `<GLOBAL>` → `!`
* `<ATTRIBUTE>` → `@`
* `<COMMENT>` → `#`
* `<NAME>` → **__s'__**
* `<KEYVALUE>` → `<VALUE>` | `<KEY>=<VALUE>` | `<VALUE><DELIMITER><KEYVALUE>`
    | `<KEY>=<VALUE><DELIMITER><KEYVALUE>` | **__ϵ__**
* `<DELIMITER>` → ` ` | `,`
* `<KEY>` → `<RAWTOKEN>`
* `<VALUE>` → `<RAWTOKEN>`
* `<RAWTOKEN>` → `<TOKEN>` | `"<TOKEN>"`
* `<TOKEN>` → **__s__**

#### Reserved Characters
The following characters are used in YES spec and **cannot** be\
used for element names:
1. `!`
2. `#`
3. `@`
4. `,`

If these characters are sounded by quotes (see `<RAWTOKEN>` generation),\
then these characters can be safely used.

# Getting Started
The dart API provides two constructors: parsing by file or parsing by string.
These constructors require the callback function to be set via `.then(...)`.

Loading by file is asynchronous and must be waited on for completion
```dart
void main() async {
  final p = YesParser.fromFile(File.fromUri(Uri.file("example.mesh")))
    ..then(onComplete);

  // Wait for parser to finish before ending program
  await p.join();
}

void onComplete(List<Element> elements, List<ErrorInfo> errors) { ... }
```

Loading by string is synchronous and can be used immediately.
```dart
void main() {
  final p = YesParser.fromFile("...")
    ..then(onComplete);
}

void onComplete(List<Element> elements, List<ErrorInfo> errors) { ... }
```

See the [example](./example/yes_parser_example.dart) to learn how to access
element types and their data from a [mesh file format](./example/example.mesh)
which uses the YES scriplet spec.