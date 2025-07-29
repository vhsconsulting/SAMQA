create index samqa.user_security_info_n2 on
    samqa.user_security_info (
        pw_question2
    );


-- sqlcl_snapshot {"hash":"4aa6634ea239a5b4a11321ab9e4057f4a93ec01b","type":"INDEX","name":"USER_SECURITY_INFO_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>USER_SECURITY_INFO_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>USER_SECURITY_INFO</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PW_QUESTION2</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}