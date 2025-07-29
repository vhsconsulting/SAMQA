create index samqa.online_renewals_n2 on
    samqa.online_renewals (
        acc_id
    );


-- sqlcl_snapshot {"hash":"628c775a1776ead89f80e672eb5e53582b9dac1a","type":"INDEX","name":"ONLINE_RENEWALS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_RENEWALS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_RENEWALS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}