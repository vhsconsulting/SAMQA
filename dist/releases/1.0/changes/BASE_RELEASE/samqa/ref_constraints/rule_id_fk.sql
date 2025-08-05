-- liquibase formatted sql
-- changeset SAMQA:1754374147278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\rule_id_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/rule_id_fk.sql:null:63b618b58c85961bdcd668a63ba0818cf113c78b:create

alter table samqa.deductible_rule_detail
    add constraint rule_id_fk
        foreign key ( rule_id )
            references samqa.deductible_rule ( rule_id )
        enable;

