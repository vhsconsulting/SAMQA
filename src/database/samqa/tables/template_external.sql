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


-- sqlcl_snapshot {"hash":"686357f97593159f229f13f3df00677bc4b0e7d4","type":"TABLE","name":"TEMPLATE_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>TEMPLATE_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LINE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>3200</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>ENROLL_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>RECORDS DELIMITED BY NEWLINE\n        PREPROCESSOR etl_script:'save_head.sh'\n        NOBADFILE NODISCARDFILE\n         FIELDS TERMINATED BY ';' \n        </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>ENROLL_DIR</DIRECTORY>\n                  <NAME>BooksyInc_HSA_Eligibility_07172025.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>0</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}