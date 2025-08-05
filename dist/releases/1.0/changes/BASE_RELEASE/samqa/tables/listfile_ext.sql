-- liquibase formatted sql
-- changeset SAMQA:1754374160083 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\listfile_ext.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/listfile_ext.sql:null:a96585f447795f4fa1d23053a04139f88f0e63ca:create

create table samqa.listfile_ext (
    fpermission varchar2(500 byte),
    flink       varchar2(2 byte),
    fowner      varchar2(500 byte),
    fgroup      varchar2(500 byte),
    fsize       varchar2(500 byte),
    fdate       varchar2(20 byte),
    ftime       varchar2(20 byte),
    fname       varchar2(500 byte)
)
organization external ( type oracle_loader
    default directory scripts access parameters (
        records delimited by newline
            preprocessor scripts : 'list_files.sh'
            skip 2
            badfile scripts : 'listfile_ext%a_%p.bad'
            logfile scripts : 'listfile_ext%a_%p.log'
        fields terminated by ',' lrtrim missing field values are null (
            fpermission,
            flink,
            fowner,
            fgroup,
            fsize,
            fdate,
            ftime,
            fname
        )
    ) location ( scripts : 'list_files.sh' )
) reject limit unlimited
    parallel 2;

