create index samqa.notif_participants_n1 on
    samqa.notif_participants (
        notification_id
    );


-- sqlcl_snapshot {"hash":"eddffbc22813d0eb856e4856cc39a3e5c8212d21","type":"INDEX","name":"NOTIF_PARTICIPANTS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>NOTIF_PARTICIPANTS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NOTIF_PARTICIPANTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>NOTIFICATION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}