-- liquibase formatted sql
-- changeset SAMQA:1754374147324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\userkoa_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/userkoa_pers.sql:null:86b2c26bb5437b3d3744fa46cbda7fe511404ede:create

alter table samqa.userkoa
    add constraint userkoa_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;

