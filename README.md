# Телеграм бот космической стратегии

Бот написан на JavaScript на движке QmlEngine Qt5.

В качестве сервера используется ПО собственной разработки - SHS Server, который написан на С++ и Qt5. 

Для разработки применяется самописное IDE - **Server Designer**, так же написан на Qt5.
Скачать Server Designer можно тут:
* [Server Designer для Windows](https://shs.tools/packages/utils/server_designer_0.99.0_alpha_windows_x86_64.zip)
* [Server Designer для Mac](https://shs.tools/packages/utils/server_designer_0.99.0_alpha_macosx_x64.dmg.zip)
* [Server Designer для Ubuntu 20.04](https://shs.tools/packages/utils/server_designer_0.99.0_alpha_ubuntu20.04_amd64.deb)
* [Server Designer для Debian 10](https://shs.tools/packages/utils/server_designer_0.99.0_alpha_debian10_amd64.deb)


## Как начать разработку
Для начала разработки и тестирования необходим только Server Designer.
1. Запустить server_designer
2. Открыть в нём файл роекта *game.spd*
3. В файле скрипта *main.qs* найти строчку `const isProduction = true;` и заменить на `const isProduction = false;`
4. В файле скрипта *main.qs* найти строчку `Telegram.start("/bot_token/");` и вписать туда токен своего бота, на котором собираетесь тестировать. (создать бота можно тут: https://telegram.me/botfather )
5. Для запуска нажать "Test with form" или F12
6. Бот запущен
