-- liquibase formatted sql
-- changeset SAMQA:1754374163701 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\template_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/template_external.sql:null:a7471644e34b2a4ade4b4fa6a0baf38618057fed:create

create table samqa.template_external (
    line varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            preprocessor etl_script : 'save_head.sh'
            nobadfile
            nodiscardfile
        fields terminated by ';'
    ) location ( enroll_dir : 'FSAHRA.csv' )
) reject limit 0;

