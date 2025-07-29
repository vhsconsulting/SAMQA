create table samqa.cms_msp_external (
    hic_number          char(12 byte),
    sur_name            char(6 byte),
    first_name          char(1 byte),
    birth_date          char(8 byte),
    sex                 char(1 byte),
    dcn                 char(15 byte),
    transaction_type    char(1 byte),
    coverage_type       char(1 byte),
    ssn                 char(9 byte),
    effective_date      char(8 byte),
    termination_date    char(8 byte),
    relationship_code   char(2 byte),
    policy_holder_fname char(9 byte),
    policy_holder_lname char(16 byte),
    policy_holder_ssn   char(9 byte),
    employer_size       char(1 byte),
    group_policy_number char(20 byte),
    ind_policy_number   char(17 byte),
    subscriber_only     char(1 byte),
    employee_status     char(1 byte),
    tin                 char(9 byte),
    tpa_tin             char(9 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields (
            hic_number position ( 1 : 12 ) char ( 12 ),
            sur_name position ( 13 : 18 ) char ( 6 ),
            first_name position ( 19 : 19 ) char ( 1 ),
            birth_date position ( 20 : 27 ) char ( 8 ),
            sex position ( 28 : 28 ) char ( 1 ),
            dcn position ( 29 : 43 ) char ( 15 ),
            transaction_type position ( 44 : 44 ) char ( 1 ),
            coverage_type position ( 45 : 45 ) char ( 1 ),
            ssn position ( 46 : 54 ) char ( 9 ),
            effective_date position ( 55 : 63 ) char ( 8 ),
            termination_date position ( 63 : 70 ) char ( 8 ),
            relationship_code position ( 71 : 72 ) char ( 2 ),
            policy_holder_fname position ( 73 : 81 ) char ( 9 ),
            policy_holder_lname position ( 82 : 97 ) char ( 16 ),
            policy_holder_ssn position ( 98 : 106 ) char ( 9 ),
            employer_size position ( 107 : 107 ) char ( 1 ),
            group_policy_number position ( 108 : 127 ) char ( 20 ),
            ind_policy_number position ( 128 : 143 ) char ( 17 ),
            subscriber_only position ( 145 : 145 ) char ( 1 ),
            employee_status position ( 145 : 146 ) char ( 1 ),
            tin position ( 147 : 155 ) char ( 9 ),
            tpa_tin position ( 156 : 165 ) char ( 9 )
        )
    ) location ( 'CMS_MSP_081402017093609.txt' )
) reject limit unlimited;


-- sqlcl_snapshot {"hash":"623d71d3ea5edf1831a2d132d4e20612215a5379","type":"TABLE","name":"CMS_MSP_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CMS_MSP_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>HIC_NUMBER</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>12</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SUR_NAME</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>6</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FIRST_NAME</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BIRTH_DATE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>8</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SEX</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DCN</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_TYPE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>COVERAGE_TYPE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>9</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>EFFECTIVE_DATE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>8</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TERMINATION_DATE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>8</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>RELATIONSHIP_CODE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>2</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>POLICY_HOLDER_FNAME</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>9</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>POLICY_HOLDER_LNAME</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>16</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>POLICY_HOLDER_SSN</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>9</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYER_SIZE</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>GROUP_POLICY_NUMBER</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>IND_POLICY_NUMBER</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>17</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SUBSCRIBER_ONLY</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYEE_STATUS</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TIN</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>9</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TPA_TIN</NAME>\n            <DATATYPE>CHAR</DATATYPE>\n            <LENGTH>9</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>DEBIT_CARD_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited by newline\n     fields (\n\t   HIC_Number\t\tposition(1:12)\tchar(12),\n\t   Sur_name\t\tposition(13:18)\tchar(6),\n\t   First_name\t\tposition(19:19)\tchar(1),\n\t   birth_date\t\tposition(20:27)\tchar(8),\n\t   Sex\t\t\tposition(28:28)\tchar(1),\n\t   DCN\t\t\tposition(29:43)\tchar(15),\n\t   Transaction_Type\tposition(44:44)\tchar(1),\n\t   Coverage_Type\tposition(45:45)\tchar(1),\n\t   SSN\t\t\tposition(46:54)\tchar(9),\n\t   Effective_Date\tposition(55:63)\tchar(8),\n\t   Termination_Date\tposition(63:70)\tchar(8),\n\t   Relationship_Code    position(71:72)  char(2),\n\t   Policy_Holder_FName\tposition(73:81)\tchar(9),\n\t   Policy_Holder_LName\tposition(82:97)\tchar(16),\n\t   Policy_Holder_ssn\tposition(98:106)\tchar(9),\n\t   Employer_Size\tposition(107:107)\tchar(1),\n\t   Group_Policy_Number\tposition(108:127)\tchar(20),\n\t   Ind_Policy_Number\tposition(128:143)\tchar(17),\n\t   Subscriber_Only\tposition(145:145)\tchar(1),\n\t   Employee_Status\tposition(145:146)\tchar(1),\n\t   TIN\t\t\tposition(147:155)\tchar(9),\n\t   TPA_tIN\t\tposition(156:165)\tchar(9)\n    )\n      </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <NAME>CMS_MSP_081402017093609.txt</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}