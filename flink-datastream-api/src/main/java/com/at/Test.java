//package com.at;
//
//import com.alibaba.fastjson.JSONObject;
//import com.alibaba.ververica.cdc.connectors.mysql.MySQLSource;
//import com.alibaba.ververica.cdc.debezium.DebeziumDeserializationSchema;
//import com.at.pojo.Event;
//import com.at.source.ClickSource;
//import io.debezium.data.Envelope;
//import org.apache.flink.api.common.restartstrategy.RestartStrategies;
//import org.apache.flink.api.common.typeinfo.TypeInformation;
//import org.apache.flink.api.java.tuple.Tuple2;
//import org.apache.flink.runtime.state.filesystem.FsStateBackend;
//import org.apache.flink.streaming.api.CheckpointingMode;
//import org.apache.flink.streaming.api.datastream.DataStreamSource;
//import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
//import org.apache.flink.streaming.api.functions.source.SourceFunction;
//import org.apache.flink.util.Collector;
//import org.apache.kafka.connect.data.Field;
//import org.apache.kafka.connect.data.Struct;
//import org.apache.kafka.connect.source.SourceRecord;
//
//import java.util.Properties;
//
///**
// * @create 2022-05-17
// */
//public class Test {
//
//    public static void main(String[] args) throws Exception{
//
//        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
//        env.setParallelism(1);
//
//
//        env.enableCheckpointing(5000, CheckpointingMode.EXACTLY_ONCE);
//        env.setStateBackend(new FsStateBackend("file:///D:\\workspace\\flink_\\flink-api\\ck"));
//        env.setRestartStrategy(RestartStrategies.noRestart());
//
//        Properties props = new Properties();
//        props.setProperty("debezium.snapshot.mode","initial");
//
//        SourceFunction<String> sourceFunction = MySQLSource.<String>builder()
//                .hostname("hadoop102")
//                .port(3306)
//                .databaseList("table_process")// monitor all tables under inventory database
//                .tableList("table_process.test_flinkcdc")
//                .username("root")
//                .password("root")
//                .debeziumProperties(props)
//                .deserializer(new MySchema()) // converts SourceRecord to String
//                .build();
//
//        DataStreamSource<String> streamSource = env.addSource(sourceFunction);
//
//        streamSource.print();
//
//        env.execute();
//
//
//    }
//
//    public static class MySchema implements DebeziumDeserializationSchema<String> {
//
//        @Override
//        public void deserialize(SourceRecord sourceRecord, Collector<String> collector) throws Exception {
//
//            //??????????????????,??????????????????????????? mysql_binlog_source.gmall-flink-200821.z_user_info
//            String topic = sourceRecord.topic();
//            String[] arr = topic.split("\\.");
//            String db = arr[1];
//            String tableName = arr[2];
//
//            //?????????????????? READ DELETE UPDATE CREATE
//            Envelope.Operation operation = Envelope.operationFor(sourceRecord);
//
//            //???????????????????????????Struct??????
//            Struct value = (Struct) sourceRecord.value();
//
//            //????????????????????????
//            Struct after = value.getStruct("after");
//
//            //??????JSON??????????????????????????????
//            JSONObject data = new JSONObject();
//            if(after != null){
//                for (Field field : after.schema().fields()) {
//                    Object o = after.get(field);
//                    data.put(field.name(), o);
//                }
//            }
//
//
//            //??????JSON?????????????????????????????????????????????
//            JSONObject result = new JSONObject();
//            result.put("operation", operation.toString().toLowerCase());
//            result.put("data", data);
//            result.put("database", db);
//            result.put("table", tableName);
//
//            //?????????????????????
//            collector.collect(result.toJSONString());
//
//
//        }
//
//        @Override
//        public TypeInformation<String> getProducedType() {
//            return TypeInformation.of(String.class);
//        }
//    }
//
//}
