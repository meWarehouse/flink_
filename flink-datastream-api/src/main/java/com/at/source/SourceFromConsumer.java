package com.at.source;

import com.at.pojo.Event;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;


/**
 * @create 2022-05-15
 */
public class SourceFromConsumer {

    public static void main(String[] args) throws Exception {

        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        env.setParallelism(1);

        // consumer source
        DataStreamSource<Event> streamSource = env.addSource(new ClickSource());

        streamSource
                // 实现 print
                .addSink(new SinkFunction<Event>() {
                    @Override
                    public void invoke(Event value, SinkFunction.Context context) throws Exception {
                        SinkFunction.super.invoke(value, context);
                        System.out.println(value);
                    }
                });

        env.execute();

    }

//    // SourceFunction并行度只能为1
//    // 自定义并行化版本的数据源，需要使用ParallelSourceFunction
//    public static class ClickSource implements SourceFunction<Event> {
//        private boolean running = true;
//        private String[] userArr = {"Mary", "Bob", "Alice", "Liz"};
//        private String[] urlArr = {"./home", "./cart", "./fav", "./prod?id=1", "./prod?id=2"};
//        private Random random = new Random();
//
//        @Override
//        public void run(SourceContext<Event> ctx) throws Exception {
//            while (running) {
//                // collect方法，向下游发送数据
//                ctx.collect(
//                        new Event(
//                                userArr[random.nextInt(userArr.length)],
//                                urlArr[random.nextInt(urlArr.length)],
//                                Calendar.getInstance().getTimeInMillis()
//                        )
//                );
//                Thread.sleep(1000L);
//            }
//        }
//
//        @Override
//        public void cancel() {
//            running = false;
//        }
//    }


//    public static class Event {
//
//        public String user;
//        public String url;
//        public Long timestamp;
//
//
//        public Event() {
//        }
//
//        public Event(String user, String url, Long timestamp) {
//            this.user = user;
//            this.url = url;
//            this.timestamp = timestamp;
//        }
//
//        @Override
//        public String toString() {
//            return "Event{" +
//                    "user='" + user + '\'' +
//                    ", url='" + url + '\'' +
//                    ", timestamp=" + new Timestamp(timestamp) +
//                    '}';
//        }
//
//
//    }
//
}
