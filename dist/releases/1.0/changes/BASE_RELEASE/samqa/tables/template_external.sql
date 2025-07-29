-- liquibase formatted sql
-- changeset SAMQA:1753779774769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\template_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/template_external.sql:null:686357f97593159f229f13f3df00677bc4b0e7d4:create

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
    ) location ( enroll_dir : 'BooksyInc_HSA_Eligibility_07172025.csv' )
) reject limit 0;

