create index samqa.broker_f1 on
    samqa.broker ( upper(broker_lic) );


-- sqlcl_snapshot {"hash":"dca8169b15d52651a3986b317b9c34a2af10eccf","type":"INDEX","name":"BROKER_F1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_F1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BROKER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>UPPER(\"BROKER_LIC\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}