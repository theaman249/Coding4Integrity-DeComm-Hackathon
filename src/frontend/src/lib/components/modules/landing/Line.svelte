<script lang="ts">
	import { scaleLinear } from "d3-scale";
    import { line } from "d3-shape";
	import * as Card from "$lib/components/ui/card/index.js";

	// Mock data for cryptocurrency values over a period (e.g., 30 days)
	const data = Array.from({ length: 30 }, (_, i) => ({
		day: i + 1,
		value: Math.random() * 1000 + 2000 + Math.sin(i / 2) * 20, // Random crypto value simulation with some wave
	}));

	const yTicks = [2000, 2500, 3000, 3500, 4000];
	const padding = { top: 20, right: 15, bottom: 20, left: 45 };

	let width = 500;
	let height = 200;

	// Create scales for x and y axes
	$: xScale = scaleLinear()
		.domain([0, data.length - 1]) // Days from 0 to 29
		.range([padding.left, width - padding.right]);

	$: yScale = scaleLinear()
		.domain([Math.min(...data.map((d) => d.value)), Math.max(...data.map((d) => d.value))]) // Scale for values
		.range([height - padding.bottom, padding.top]);

	// Create a line generator function using D3
	const lineGenerator = line()
		.x((d, i) => xScale(i))
		.y((d) => yScale(d.value));
</script>

<Card.Root class="col-span-3">
    <Card.Header>
      <Card.Title>Knowkedge Token Market Value</Card.Title>
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
								text-anchor="end"><tspan x="36" dy="0.355em">{tick}</tspan></text
							>
						</g>
					{/each}
				</g>

				<!-- Line graph -->
				<path
					d={lineGenerator(data)}
					fill="none"
					stroke="#5eba61"
					stroke-width="2"
				/>
			</svg>
		</div>
</Card.Content>
</Card.Root> 
<style>
	.chart {
		width: 100%;
		margin: 0 auto;
		height: 280px;
	}

	svg {
		position: relative;
		width: 100%;
		height: 90%;
	}
</style>
