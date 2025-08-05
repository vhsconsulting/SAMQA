-- liquibase formatted sql
-- changeset SAMQA:1754374147131 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\opportunity_notes_fk1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/opportunity_notes_fk1.sql:null:6f96797588acbf119c12461ed60b62acf3e68f81:create

alter table samqa.opportunity_notes
    add constraint opportunity_notes_fk1
        foreign key ( opp_id )
            references samqa.opportunity ( opp_id )
        enable;

