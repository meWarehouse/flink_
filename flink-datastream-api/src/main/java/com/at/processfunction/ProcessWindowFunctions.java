package com.at.processfunction;

import com.at.pojo.Event;
import com.at.source.ClickSource;
import org.apache.flink.api.common.eventtime.SerializableTimestampAssigner;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.state.ValueState;
import org.apache.flink.api.common.state.ValueStateDescriptor;
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.windowing.ProcessWindowFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.streaming.api.windowing.triggers.Trigger;
import org.apache.flink.streaming.api.windowing.triggers.TriggerResult;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.util.Collector;

import java.sql.Timestamp;
import java.time.Duration;
import java.util.Optional;

/**
 * @create 2022-05-17
 */
public class ProcessWindowFunctions {

    public static void main(String[] args) throws Exception {

        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);


        env
                .addSource(new ClickSource())
                .assignTimestampsAndWatermarks(
                        WatermarkStrategy
                                .<Event>forBoundedOutOfOrderness(Duration.ofSeconds(0L))
                                .withTimestampAssigner(
                                        new SerializableTimestampAssigner<Event>() {
                                            @Override
                                            public long extractTimestamp(Event element, long recordTimestamp) {
                                                return element.timestamp;
                                            }
                                        }
                                )
                )
                .keyBy(event -> event.user)
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                .trigger(
                        // ???????????????????????????
                        // ?????????????????????????????????????????????
                        new Trigger<Event, TimeWindow>() {

                            // ???????????????????????????????????????
                            @Override
                            public TriggerResult onElement(Event element, long timestamp, TimeWindow window, TriggerContext ctx) throws Exception {

                                ValueState<Boolean> winFirstSeen = ctx.getPartitionedState(new ValueStateDescriptor<Boolean>("window-first-seen", Types.BOOLEAN));

                                if (!Optional.ofNullable(winFirstSeen.value()).orElseGet(() -> false)) {

                                    // ????????????????????????

                                    // ????????????????????? ??? ?????? ????????? ?????????
                                    ctx.registerEventTimeTimer(ctx.getCurrentWatermark() + (1000L - ctx.getCurrentWatermark() % 1000l));

                                    // ???????????????????????????????????????
                                    ctx.registerEventTimeTimer(window.getEnd());

                                    winFirstSeen.update(true);


                                }

                                return TriggerResult.CONTINUE;
                            }

                            // ????????????
                            @Override
                            public TriggerResult onProcessingTime(long time, TimeWindow window, TriggerContext ctx) throws Exception {
                                return TriggerResult.CONTINUE;
                            }

                            // ????????????
                            @Override
                            public TriggerResult onEventTime(long time, TimeWindow window, TriggerContext ctx) throws Exception {

                                if (time == window.getEnd()) {

                                    // ??????????????????????????????
                                    return TriggerResult.FIRE_AND_PURGE;

                                }

                                // ????????????????????????


                                // ????????????????????? ??? ?????? ????????? ?????????
                                // ??????????????????????????????????????????????????????
                                long lastOneSecTimer = ctx.getCurrentWatermark() + (1000L - ctx.getCurrentWatermark() % 1000l);
                                if (lastOneSecTimer < window.getEnd()) ctx.registerEventTimeTimer(lastOneSecTimer);


                                return TriggerResult.FIRE;
                            }

                            @Override
                            public void clear(TimeWindow window, TriggerContext ctx) throws Exception {

                                System.out.println("window [ " + new Timestamp(window.getStart()) + " - " + new Timestamp(window.getEnd()) + " ) ??????????????????");

                                ValueState<Boolean> winFirstSeen = ctx.getPartitionedState(new ValueStateDescriptor<Boolean>("window-first-seen", Types.BOOLEAN));

                                // ??????????????????
                                winFirstSeen.clear();

                            }
                        }
                )
                .process(
                        // ProcessWindowFunction<IN, OUT, KEY, W extends Window>
                        new ProcessWindowFunction<Event, String, String, TimeWindow>() {
                            @Override
                            public void process(String key, Context context, Iterable<Event> elements, Collector<String> out) throws Exception {

                                Timestamp winStart = new Timestamp(context.window().getStart());
                                Timestamp winEnd = new Timestamp(context.window().getEnd());
                                long count = elements.spliterator().getExactSizeIfKnown();

                                out.collect("key = " + key + "\twindow [ " + winStart + " - " + winEnd + " ) ??????????????? " + count + " ?????????");
                            }
                        }
                )
                .print();


        env.execute();


    }

}
