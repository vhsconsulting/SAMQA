-- liquibase formatted sql
-- changeset SAMQA:1754373925869 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.memberremittancetotalbypost.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.memberremittancetotalbypost.sql:null:eca441cd2346ea8839ad2f4df2819c90d69faab8:create

grant select on cobrap.memberremittancetotalbypost to samqa;

