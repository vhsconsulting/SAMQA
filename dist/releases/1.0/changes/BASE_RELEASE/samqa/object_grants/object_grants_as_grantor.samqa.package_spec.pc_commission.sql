-- liquibase formatted sql
-- changeset SAMQA:1754373936001 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_commission.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_commission.sql:null:fc06fdc1ec8304b54865e3b1713e7303ac1f5224:create

grant execute on samqa.pc_commission to rl_sam_ro;

grant execute on samqa.pc_commission to rl_sam_rw;

grant execute on samqa.pc_commission to rl_sam1_ro;

grant debug on samqa.pc_commission to rl_sam_ro;

grant debug on samqa.pc_commission to sgali;

grant debug on samqa.pc_commission to rl_sam_rw;

grant debug on samqa.pc_commission to rl_sam1_ro;

