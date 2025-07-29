create index samqa.account_email_alerts_n1 on
    samqa.account_email_alerts (
        acc_id
    );


-- sqlcl_snapshot {"hash":"1e9c058f95073ef1624709b47511c6cce54dee66","type":"INDEX","name":"ACCOUNT_EMAIL_ALERTS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACCOUNT_EMAIL_ALERTS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACCOUNT_EMAIL_ALERTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}