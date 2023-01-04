### Работа с последовательностями

Последовательность - это инкрементируемые данные, по умолчанию они они инкрементируются на 1.

Создание последовательности:

    CREATE SEQUENCE test_increment_it_with_sequence START 500;
    
Посмотр какое значение лежит в последовательности
  
    SELECT * FROM test_increment_it_with_sequence;
    
Увеличение значения последовательности:

    SELECT nextval ('test_increment_it_with_sequence');
    
