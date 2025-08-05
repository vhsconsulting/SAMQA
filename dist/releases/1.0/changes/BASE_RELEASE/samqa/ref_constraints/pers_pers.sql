-- liquibase formatted sql
-- changeset SAMQA:1754374147189 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\pers_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/pers_pers.sql:null:ee610379d42fd671d42d89d4349a73871264c425:create

alter table samqa.person
    add constraint pers_pers
        foreign key ( pers_main )
            references samqa.person ( pers_id )
                on delete cascade
        enable;

