<script lang="ts">
	import { scaleLinear } from "d3-scale";
    import * as Card from "$lib/components/ui/card/index.js";

	const data = [
		{
			name: "Jan",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Feb",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Mar",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Apr",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "May",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Jun",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Jul",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Aug",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Sep",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Oct",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Nov",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
		{
			name: "Dec",
			totalA: Math.floor(Math.random() * 50) + 10,
			totalB: Math.floor(Math.random() * 50) + 10,
		},
	];

	// Space between bars
	let barSpacing = 2;

	const xTicks = data.map((d) => d.name);
	const yTicks = [0, 10, 20, 30, 40, 50];
	const padding = { top: 20, right: 15, bottom: 20, left: 45 };

	let width = 500;
	let height = 200;

	function formatMobile(tick: number | string) {
		return `'${tick.toString().slice(-2)}`;
	}

	$: xScale = scaleLinear()
		.domain([0, xTicks.length])
		.range([padding.left, width - padding.right]);

	$: yScale = scaleLinear()
		.domain([0, Math.max.apply(null, yTicks)])
		.range([height - padding.bottom, padding.top]);

	$: innerWidth = width - (padding.left + padding.right);
	$: barWidth = (innerWidth / xTicks.length) + - barSpacing;
</script>

<Card.Root class="col-span-3">
    <Card.Header>
      <Card.Title>Sales</Card.Title>
    </Card.Header>
    <Card.Content>
        <div class="chart" bind:clientWidth={width} bind:clientHeight={height}>
            <svg>
                <!-- y axis -->
                <g class="axis y-axis">
                    {#each yTicks as tick}
                        <g class="text-xs" transform="translate(0, {yScale(tick)})">
                            <text
                                stroke="none"
                                font-size="12"
                                orientation="left"
                                width="60"
                                height="310"
                                x="57"
                                y="-4"
                                fill="#888888"
                                text-anchor="end"><tspan x="36" dy="0.355em">KT {tick}</tspan></text
                            >
                        </g>
                    {/each}
                </g>
        
                <!-- x axis -->
                <g class="axis x-axis">
                    {#each data as point, i}
                        <g class="text-xs" transform="translate({xScale(i)},{height})">
                            <text
                                stroke="none"
                                font-size="12"
                                orientation="bottom"
                                width="531"
                                height="30"
                                x={barWidth / 2}
                                y="-15"
                                fill="#888888"
                                text-anchor="middle"
                                ><tspan x={barWidth / 2} dy="0.71em"
                                    >{width > 380 ? point.name : formatMobile(point.name)}</tspan
                                ></text
                            >
                        </g>
                    {/each}
                </g>
        
                <g>
                    {#each data as point, i}
                        <!-- First bar (A) -->
                        <rect
                            class="bg-primary"
                            x={xScale(i) + 2}
                            y={yScale(point.totalA)}
                            width={(barWidth / 2) - 2}
                            height={yScale(0) - yScale(point.totalA)}
                            fill="#5eba61"
                            rx="4"
                            ry="4"
                        />
                    {/each}
                </g>
            </svg>
        </div>
    </Card.Content>
</Card.Root> 


<style>
	.chart {
		width: 100%;
		margin: 0 auto;
        height: fit;
	}

	svg {
		position: relative;
		width: 100%;
		height: 90%;
	}

	rect {
		max-width: 51px;
	}
</style>