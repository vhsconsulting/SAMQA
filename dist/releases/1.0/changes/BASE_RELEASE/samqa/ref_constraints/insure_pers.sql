-- liquibase formatted sql
-- changeset SAMQA:1754374147076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\insure_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/insure_pers.sql:null:223f2b14d86d93363f65bba30f78c6f791125b87:create

alter table samqa.insure
    add constraint insure_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;

