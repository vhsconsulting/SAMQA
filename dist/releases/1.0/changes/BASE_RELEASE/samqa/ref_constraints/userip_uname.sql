-- liquibase formatted sql
-- changeset SAMQA:1754374147312 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\userip_uname.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/userip_uname.sql:null:af552831043328e68de0c1e4028d6fad37f8fa53:create

alter table samqa.userip
    add constraint userip_uname
        foreign key ( uname )
            references samqa.userkoa ( uname )
        enable;

