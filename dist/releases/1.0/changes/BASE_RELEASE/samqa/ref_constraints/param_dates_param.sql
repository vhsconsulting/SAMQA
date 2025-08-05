-- liquibase formatted sql
-- changeset SAMQA:1754374147143 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\param_dates_param.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/param_dates_param.sql:null:a35bc12da9a834282360d997d9ad6c6b8d3c5e44:create

alter table samqa.param_dates
    add constraint param_dates_param
        foreign key ( param_code )
            references samqa.param ( param_code )
        enable;

