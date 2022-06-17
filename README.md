# Поиск смещений методом взаимной корреляции <br> (Search for offsets by the method of cross-correlation)

В репозитории представлена реализация метода взаимной корреляции для определения локальных смещений на паре изображений. Данная работа является предварительной реализацией алгоритма для его улучшения и переноса улучшений в проект на **C#**.

В метод добавлены: *многопроходный опрос; поиск выбросов и их интерполяция*. Что позволило повысить точность определения смещений.


## Каталоги в этом репозитории

>**demos**: папка, содержащая демонстрацию реализации на примерах <br>
>**matlab**: папка, содержащая код программы

## Запуск

Запуск осуществляется функцией `MultiplePassInterrogation`:

`[CoordStart, CoordEnd] = MultiplePassInterrogation(Image1, Image2, SizeWindow, CrossWindow, Iters, Indent, Scale)`

где **Image1** и **Image2** – обрабатываемые изображения; **SizeWindow** – размер окна опроса в пикселях; **CrossWindow** – величина перекрытия окон опроса в пикселях; **Iters** – число итераций многопроходного опроса; **Indent** – отступ от края изображения в размере окна опроса, кратен **0,5**; **Scale** – параметр отображения векторного поля.
В **CoordStart** и **CoordEnd** записываются координаты начала и конца векторов

## Ограничения

В программе не предусмотрен выход за пределы изображения при многопроходном опросе.

## Примеры

Здесь приведён пример работы на известном примере из области **PIV**:

`[CoordStart, CoordEnd] = MultiplePassInterrogation(Image1, Image2, 32, 24, 3, 0.5, "Auto");`

<p float="left">
<img src="https://github.com/Stergrim/Offset-search-by-the-method-of-cross-correlation/blob/main/demos/VortexPair.gif" width="300" />
<img src="https://github.com/Stergrim/Offset-search-by-the-method-of-cross-correlation/blob/main/demos/VortexPair.png" width="300" /> 
</p>

Пример работы на листе бумаги с рисунком имитирующем спекл картину:

`[CoordStart, CoordEnd] = MultiplePassInterrogation(Image1, Image2, 96, 64, 3, 0.5, "NoAuto");`

<p float="left">
<img src="https://github.com/Stergrim/Offset-search-by-the-method-of-cross-correlation/blob/main/demos/SheetSurface.gif" width="300" />
<img src="https://github.com/Stergrim/Offset-search-by-the-method-of-cross-correlation/blob/main/demos/SheetSurface.png" width="300" /> 
</p>