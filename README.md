###  OFDM Homeworks

- my_functions - functions from 6-th semmester (no need)
- my_functions_2 - functions from current semmester

- ofdm_sim_main.m -file that you should run to begin modulation
    In "SETTINGS" part you can configure system:
    - Enable clipping
    - Enable srcambler 
    - Enable cyclic prefix mode
    - Enable SNR calculation
    - Enable CCDF calculation (dont forget to disable SNR calculation)
    - Enable logging information
    - Enable pictures showing

- figures/ - folder with .mat data for figures

- run opener.m to see figures


---

##### Почему график BER-SNR для скрэмблера находится немного ниже графика без скрэмблера?

Я вычислил среднюю мощность сигнала 'x', который поступает в канал. Оказалось, что в сисиеме со скрэмблером мощность сигнала меншьше. В этом можно убедиться, если посмотреть на график "power comparation". Соответственно зашумление AWGN также происходит с меньшей мощностью, так как выставлен флаг "Measured". Меньшей зашумленности соответствует меньшая ошибка. Я полагаю, что причина заключается в этом.
После этого я отнормировал мощность поступающего в канал сигнала к 20dBm однако разница в графике BER-SNR сохранилась.
 Значит дело не в разных мощностях. Единственное оставшееся предположение - это положить, что причина в механизме зашумления в 
 функции AWGN.


##### Нахождение оптимального CR
Не знаю, почему, но у меня так и не получилось победить метод со скрамблэром добавляя клиппинг. Я и перешел на 16-qam и 
поднял нормировку мощности до 25dbm, не помогло. Мощность сигнала поступающего на усилитель можно посмотреть, если 
включить clipping_effect_sh = "on". Я вроде так и поставил.
