alter table samqa.param_dates
    add constraint param_dates_param
        foreign key ( param_code )
            references samqa.param ( param_code )
        enable;


-- sqlcl_snapshot {"hash":"a35bc12da9a834282360d997d9ad6c6b8d3c5e44","type":"REF_CONSTRAINT","name":"PARAM_DATES_PARAM","schemaName":"SAMQA","sxml":""}