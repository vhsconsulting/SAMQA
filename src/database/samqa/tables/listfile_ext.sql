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


-- sqlcl_snapshot {"hash":"a96585f447795f4fa1d23053a04139f88f0e63ca","type":"TABLE","name":"LISTFILE_EXT","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>LISTFILE_EXT</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>FPERMISSION</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>500</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FLINK</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>2</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FOWNER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>500</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FGROUP</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>500</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FSIZE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>500</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FDATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FTIME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FNAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>500</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>SCRIPTS</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>RECORDS DELIMITED BY NEWLINE\n         PREPROCESSOR SCRIPTS: 'list_files.sh'\n         skip 2\n         badfile SCRIPTS:'listfile_ext%a_%p.bad'\n         logfile SCRIPTS:'listfile_ext%a_%p.log'\n         fields terminated by ',' lrtrim\n         missing field values are null (fpermission,\n                                        flink ,\n                                        fowner ,\n                                        fgroup ,\n                                        fsize ,\n                                        fdate,\n                                        ftime ,\n                                        FNAME )\n                                               </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>SCRIPTS</DIRECTORY>\n                  <NAME>list_files.sh</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n      <TABLE_PROPERTIES>\n         <PARALLEL>2</PARALLEL>\n      </TABLE_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}