create index samqa.metavante_authorizations_n1 on
    samqa.metavante_authorizations (
        acc_num
    );


-- sqlcl_snapshot {"hash":"b172d5fb6d2458b7298332490a408c6c0244ae34","type":"INDEX","name":"METAVANTE_AUTHORIZATIONS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_AUTHORIZATIONS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_AUTHORIZATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}