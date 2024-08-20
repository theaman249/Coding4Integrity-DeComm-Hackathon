<script>
  import { Button } from "$lib/components/ui/button";
  import { Label } from "$lib/components/ui/label";
  import * as RadioGroup from "$lib/components/ui/radio-group";
</script>

<div class="grid grid-cols-12 items-center pl-10 min-h-screen max-h-screen overflow-hidden">
    <div class="col-span-12 block">
        <p class="mb-5">Sort:</p>
        <RadioGroup.Root value="option-one">
            <div class="flex items-center space-x-2">
              <RadioGroup.Item value="option-one" id="option-one" />
              <Label for="option-one">Name Ascending</Label>
            </div>
            <div class="flex items-center space-x-2">
              <RadioGroup.Item value="option-two" id="option-two" />
              <Label for="option-two">Name Descending</Label>
            </div>
            <div class="flex items-center space-x-2">
                <RadioGroup.Item value="option-three" id="option-three" />
                <Label for="option-three">Price Ascending</Label>
              </div>
            <div class="flex items-center space-x-2">
                <RadioGroup.Item value="option-four" id="option-four" />
                <Label for="option-four">Price Descending</Label>
            </div>
            <div class="flex items-center space-x-2">
                <RadioGroup.Item value="option-five" id="option-five" />
                <Label for="option-five">Date Listed Ascending</Label>
              </div>
              <div class="flex items-center space-x-2">
                <RadioGroup.Item value="option-six" id="option-six" />
                <Label for="option-six">Date Listed Descending</Label>
              </div>
        </RadioGroup.Root>
        <div class="flex justify-end mr-5">
          <Button class="mt-10">Apply</Button>
        </div>
    </div>
</div>
