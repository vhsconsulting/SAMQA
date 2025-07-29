create index samqa.metavante_settlements_n4 on
    samqa.metavante_settlements (
        acc_num
    );


-- sqlcl_snapshot {"hash":"01da9e74c3d5319c233d501b292c23fac73b3164","type":"INDEX","name":"METAVANTE_SETTLEMENTS_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_SETTLEMENTS_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_SETTLEMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}