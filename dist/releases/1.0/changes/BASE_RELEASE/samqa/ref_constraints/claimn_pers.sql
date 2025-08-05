-- liquibase formatted sql
-- changeset SAMQA:1754374146915 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\claimn_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/claimn_pers.sql:null:47b4f3867678f533e57c7053aa98f4af0f55cb3c:create

alter table samqa.claimn
    add constraint claimn_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;

