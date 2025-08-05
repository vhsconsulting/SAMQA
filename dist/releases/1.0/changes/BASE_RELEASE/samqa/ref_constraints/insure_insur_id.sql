-- liquibase formatted sql
-- changeset SAMQA:1754374147065 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\insure_insur_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/insure_insur_id.sql:null:876737d58320f4cbff395ed58a641fe9f193210c:create

alter table samqa.insure
    add constraint insure_insur_id
        foreign key ( insur_id )
            references samqa.enterprise ( entrp_id )
        enable;

